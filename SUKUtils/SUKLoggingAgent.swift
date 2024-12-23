//
//  SUKLogginAgent.swift
//  SwiftUpdateKit Core Utilities (SUK)
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
import os.log

@available(macOS 15.0, *)
public struct SUKLoggingAgent {
    private static let subsystem = "com.scribblefoundation.swiftupdatekit"
    
    public enum SUKLoggingCategory: String {
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case critical = "CRITICAL"
        
        var logInstance: OSLog {
            return OSLog(
                subsystem: SUKLoggingAgent.subsystem,
                category: self.rawValue
            )
        }
    }
    
    public static func log(
        message: String,
        category: SUKLoggingCategory,
        type: OSLogType = .default
    ) {
        let log = category.logInstance
        os_log("%{public}@", log: log, type: type, message)
    }
    
    public static func log(
        message: String,
        category: SUKLoggingCategory,
        type: OSLogType = .default,
        with metadata: [String: Any]? = nil
    ) {
        var fullMessage = message
        if let metadata = metadata {
            for (key, value) in metadata {
                fullMessage += " | \(key): \(value)"
            }
        }
        let log = category.logInstance
        os_log("%{public}@", log: log, type: type, fullMessage)
    }
}
