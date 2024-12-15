//
//  SUKUpdateManager.swift
//  SwiftUpdateKit Core (SUK)
//
//  Copyright (c) Nevio Hirani - All rights reserved.
//  Copyright (c) ScribbleLabApp LLC. - All rights reserved.
//
//  Usage requires copyright mention of the project authors.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

@available(macOS 15.0, *) @MainActor
public class SUKUpdateManager {
    static let shared = SUKUpdateManager()
    
    func getReleaseFeed(
        owner: String,
        repository: String,
        completion: @Sendable @escaping (Result<SUKReleaseFeed, SUKError>) -> Void
    ) {
        let urlString = "https://github.com/\(owner)/\(repository)/releases.atom"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(.failure(
                    SUKError(
                        domain: "SUKUpdateManager.Networking",
                        code: .invalidURL,
                        userInfo: ["description": "Invalid URL for the release feed."]
                    )
                ))
            }
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    return completion(.failure(
                        SUKError(
                            domain: "SUKUpdateManager.Networking",
                            code: .networkError,
                            userInfo: ["description": error.localizedDescription]
                        )
                    ))
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    return completion(.failure(
                        SUKError(
                            domain: "SUKUpdateManager.Networking",
                            code: .invalidResponse,
                            userInfo: ["description": "Invalid HTTP response."]
                        )
                    ))
                }
                
                guard let data = data else {
                    return completion(.failure(
                        SUKError(
                            domain: "SUKUpdateManager.Networking",
                            code: .noDataReceived,
                            userInfo: ["description": "No data received from the server."]
                        )
                    ))
                }
                
                do {
                    let releaseFeed = try self.parseReleaseFeed(data: data)
                    completion(.success(releaseFeed))
                } catch {
                    completion(.failure(
                        SUKError(
                            domain: "SUKUpdateManager.Parsing",
                            code: .parsingFailed,
                            userInfo: ["description": "Failed to parse release feed."]
                        )
                    ))
                }
            }
        }
        
        task.resume()
    }
    
    func parseReleaseFeed(data: Data) throws -> SUKReleaseFeed {
        let parser = XMLParser(data: data)
        let feedParserDelegate = SUKReleaseFeedParserDelegate()
        
        parser.delegate = feedParserDelegate
        
        guard parser.parse() else {
            if let error = feedParserDelegate.error {
                throw SUKError(
                    domain: "SUKUpdateManager.Parsing",
                    code: .parsingFailed,
                    userInfo: ["description": error.localizedDescription]
                )
            } else {
                throw SUKError(
                    domain: "SUKUpdateManager.Parsing",
                    code: .parsingFailed,
                    userInfo: ["description": "Unknown error occurred during XML parsing."]
                )
            }
        }
        
        return SUKReleaseFeed(
            title: feedParserDelegate.title ?? "Unknown",
            description: feedParserDelegate.description,
            link: feedParserDelegate.link ?? "",
            updated: feedParserDelegate.updated ?? Date(),
            entries: feedParserDelegate.entries
        )
    }
}
