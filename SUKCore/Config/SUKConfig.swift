//
//  SUKConfig.swift
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

@available(macOS 15.0, *)
public struct SUKConfig {
    public var feedURL: URL
    public var autoCheckInterval: SUKAutoCheckInterval
    public var updateChannels: [SUKUpdateChannel]
    public var autoUpdateEnabled: Bool? = true
    public var enableDeltaUpdates: Bool? = true
    public var channelPriorities: [SUKUpdateChannel]? = [.stable]
    
    fileprivate func validateSUKConfig() {}
    
    public enum SUKAutoCheckInterval {
        case never
        case daily
        case weekly
        case monthly
        case fixed(min: Int)
        
        public var rawValue: Int {
            switch self {
            case .never: return 0
            case .daily: return 1440
            case .weekly: return 10080
            case .monthly: return 43200
            case .fixed(let min): return min
            }
        }
        
        public var description: String {
            switch self {
            case .never: return "Never"
            case .daily: return "Daily"
            case .weekly: return "Weekly"
            case .monthly: return "Monthly"
            case .fixed(let min): return "Every \(min) minutes"
            }
        }
        
        public static func from(rawValue: Int) -> SUKAutoCheckInterval {
            switch rawValue {
            case 0: return .never
            case 1440: return .daily
            case 10080: return .weekly
            case 43200: return .monthly
            default: return .fixed(min: rawValue)
            }
        }
    }
    
    public init(
        feedURL: URL,
        autoCheckInterval: SUKAutoCheckInterval,
        updateChannels: [SUKUpdateChannel],
        autoUpdateEnabled: Bool = true,
        enableDeltaUpdates: Bool = true,
        channelPriorities: [SUKUpdateChannel] = [.stable]
    ) {
        guard feedURL.scheme == "https" else {
            fatalError("feedURL must be HTTPS for security reasons.")
        }
        self.feedURL = feedURL
        self.autoCheckInterval = autoCheckInterval
        self.updateChannels = updateChannels
        self.autoUpdateEnabled = autoUpdateEnabled
        self.enableDeltaUpdates = enableDeltaUpdates
        self.channelPriorities = channelPriorities
        validateSUKConfig()
    }
    
    public func withAutoUpdateEnabled(_ enabled: Bool) -> SUKConfig {
        var copy = self
        copy.autoUpdateEnabled = enabled
        return copy
    }
    
    public func withDeltaUpdatesEnabled(_ enabled: Bool) -> SUKConfig {
        var copy = self
        copy.enableDeltaUpdates = enabled
        return copy
    }
    
    public func withChannelPriorities(_ channels: [SUKUpdateChannel]) -> SUKConfig {
        var copy = self
        copy.channelPriorities = channels
        return copy
    }
}
