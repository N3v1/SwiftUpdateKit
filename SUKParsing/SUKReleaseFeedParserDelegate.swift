//
//  SUKReleaseFeedParseDelegate.swift
//  SwiftUpdateKit Core Parsing (SUK)
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

@available(macOS 15.0, *)
class SUKReleaseFeedParserDelegate: NSObject, XMLParserDelegate {
    var title: String?
    var feedDescription: String?
    var link: String?
    var updated: Date?
    var entries: [SUKReleaseFeed.SUKEntry] = []
    var currentAuthorUri: String?
    
    private var currentElement: String?
    private var currentTitle: String?
    private var currentLink: String?
    private var currentUpdated: String?
    private var currentSummary: String?
    private var currentId: String?
    private var currentAuthor: String?
    private var currentAssetLink: String?
    private var currentCategory: String?
    var error: Error?
    
    private let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        currentElement = elementName
        
        if elementName == "entry" {
            currentTitle = nil
            currentLink = nil
            currentUpdated = nil
            currentSummary = nil
            currentAuthorUri = nil
        }
        
        if elementName == "link", let href = attributeDict["href"] {
            currentLink = href
        }
        
        if elementName == "author", let uri = attributeDict["uri"] {
            currentAuthorUri = uri
        }
    }
    
    func parser(
        _ parser: XMLParser,
        foundCharacters string: String
    ) {
        guard let currentElement = currentElement else { return }
        
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedString.isEmpty else { return }
        
        switch currentElement {
        case "title":
            if currentTitle != nil {
                currentTitle? += trimmedString
            } else {
                currentTitle = trimmedString
            }
        case "summary":
            if currentSummary != nil {
                currentSummary? += trimmedString
            } else {
                currentSummary = trimmedString
            }
        case "updated":
            if currentUpdated != nil {
                currentUpdated? += trimmedString
            } else {
                currentUpdated = trimmedString
            }
        case "description":
            if feedDescription != nil {
                feedDescription? += trimmedString
            } else {
                feedDescription = trimmedString
            }
        case "id":
            if currentId != nil {
                currentId? += trimmedString
            } else {
                currentId = trimmedString
            }
        case "author":
            if currentAuthor != nil {
                currentAuthor? += trimmedString
            } else {
                currentAuthor = trimmedString
            }
        case "assetLink":
            if currentAssetLink != nil {
                currentAssetLink? += trimmedString
            } else {
                currentAssetLink = trimmedString
            }
        case "link":
            break
        case "category":
            break
        default:
            break
        }
    }
    
    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        if elementName == "entry" {
            if let title = currentTitle,
               let linkString = currentLink,
               let link = URL(string: linkString),
               let updatedString = currentUpdated,
               let updated = iso8601Formatter.date(from: updatedString),
               let id = currentId,
               let authorString = currentAuthor,
               let authorUriString = currentAuthorUri,
               let authorUri = URL(string: authorUriString),
               let assetLinkString = currentAssetLink,
               let assetLink = URL(string: assetLinkString),
               let category = currentCategory {
                let author = SUKReleaseFeed.SUKAuthor(
                    name: authorString, uri: authorUri
                )
                let entry = SUKReleaseFeed.SUKEntry(
                    title: title,
                    link: link,
                    id: id,
                    updated: updated,
                    published: updated,
                    author: author,
                    summary: currentSummary ?? "",
                    assetLink: assetLink,
                    category: category
                )
                entries.append(entry)
            }
        }
        
        currentElement = nil
    }
    
    func parser(
        _ parser: XMLParser,
        parseErrorOccurred parseError: Error
    ) {
        error = parseError
    }
}
