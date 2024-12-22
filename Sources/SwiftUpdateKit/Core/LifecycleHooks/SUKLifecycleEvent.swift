//
//  SUKLifeCyleEvent.swift
//  SwiftUpdateKit Core Lifecycles (SUK)
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
public class SUKLifeCycleEvent: @unchecked Sendable {
    // MARK: - Singleton
    public static let shared = SUKLifeCycleEvent()
    
    // MARK: - Private Properties
    private let queue = DispatchQueue(
        label: "com.scribblefoundation.swiftupdatekit.lifecycle",
        attributes: .concurrent
    )

    private var willStartUpdateHandlers: [() -> Void] = []
    private var didFinishUpdateHandlers: [() -> Void] = []
    private var didFailUpdateHandlers: [(Error) -> Void] = []
    private var onUpdateDownloadedHandlers: [(SUKRelease) -> Void] = []
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Lifecycle Hook Registration
    public func onWillStartUpdate(_ handler: @escaping @Sendable () -> Void) {
        queue.async(flags: .barrier) {
            self.willStartUpdateHandlers.append(handler)
        }
    }
    
    public func onDidFinishUpdate(_ handler: @escaping @Sendable () -> Void) {
        queue.async(flags: .barrier) {
            self.didFinishUpdateHandlers.append(handler)
        }
    }
    
    public func onDidFailUpdate(_ handler: @escaping @Sendable (Error) -> Void) {
        queue.async(flags: .barrier) {
            self.didFailUpdateHandlers.append(handler)
        }
    }
    
    public func onUpdateDownloaded(_ handler: @escaping @Sendable (SUKRelease) -> Void) {
        queue.async(flags: .barrier) {
            self.onUpdateDownloadedHandlers.append(handler)
        }
    }
    
    // MARK: - Trigger Lifecycle Events
    func triggerWillStartUpdate() {
        queue.async {
            self.willStartUpdateHandlers.forEach { $0() }
        }
    }
    
    func triggerDidFinishUpdate() {
        queue.async {
            self.didFinishUpdateHandlers.forEach { $0() }
        }
    }
    
    func triggerDidFailUpdate(with error: Error) {
        queue.async {
            self.didFailUpdateHandlers.forEach { $0(error) }
        }
    }
    
    func triggerOnUpdateDownloaded(for release: SUKRelease) {
        queue.async {
            self.onUpdateDownloadedHandlers.forEach { $0(release) }
        }
    }
}
