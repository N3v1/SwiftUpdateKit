//
//  SUKError.swift
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
public struct SUKError: Error, Sendable {
    public let domain: String
    public let code: SUKErrorCode
    public let userInfo: [String: String]?
    
    public enum SUKErrorCode: Int64, Sendable {
        // MARK: - Network Errors
        case invalidURL = -1000
        case networkError = -1001
        case timeout = -1002
        case noInternetConnection = -1003
        case dnsLookupFailed = -1004
        case sslError = -1005
        case redirectionLimitReached = -1006
        
        // MARK: - HTTP Errors
        case unauthorizedAccess = -2000
        case forbidden = -2001
        case resourceNotFound = -2002
        case methodNotAllowed = -2003
        case conflict = -2004
        case payloadTooLarge = -2005
        case unsupportedMediaType = -2006
        case tooManyRequests = -2007
        case serverError = -2008
        case serviceUnavailable = -2009
        case gatewayTimeout = -2010
        
        // MARK: - Data Errors
        case noDataReceived = -3000
        case invalidResponse = -3001
        case parsingFailed = -3002
        case dataCorruption = -3003
        case jsonDecodingFailed = -3004
        case xmlParsingFailed = -3005
        
        // MARK: - Update Management Errors
        case invalidReleaseFormat = -4000
        case releaseNotFound = -4001
        case incompatibleUpdate = -4002
        case updateFailed = -4003
        case updateAlreadyInProgress = -4004
        case updateCancelled = -4005
        case insufficientPermissions = -4006
        case updateChecksumMismatch = -4007
        case updateFileNotFound = -4008
        
        // MARK: - Authentication Errors
        case missingCredentials = -5000
        case invalidToken = -5001
        case tokenExpired = -5002
        case accessRevoked = -5003
        case captchaRequired = -5004
        
        // MARK: - File System Errors
        case fileNotFound = -6000
        case insufficientStorage = -6001
        case writeFailed = -6002
        case readFailed = -6003
        case permissionDenied = -6004
        
        // MARK: - Configuration Errors
        case missingConfiguration = -7000
        case invalidConfiguration = -7001
        case featureNotSupported = -7002
        
        // MARK: - General Errors
        case unknown = -8000
        case operationCancelled = -8001
        case invalidState = -8002
        case dependencyUnavailable = -8003
        
        // MARK: - Error Descriptions
        public var description: String {
            switch self {
            case .invalidURL: return "The URL provided is invalid."
            case .networkError: return "A network error occurred."
            case .timeout: return "The request timed out."
            case .noInternetConnection: return "No internet connection is available."
            case .dnsLookupFailed: return "DNS lookup failed."
            case .sslError: return "An SSL error occurred."
            case .redirectionLimitReached: return "Too many redirections occurred while processing the request."
                
            case .unauthorizedAccess: return "Unauthorized access. Please check your credentials."
            case .forbidden: return "Access to the resource is forbidden."
            case .resourceNotFound: return "The requested resource was not found."
            case .methodNotAllowed: return "The HTTP method is not allowed for this resource."
            case .conflict: return "A conflict occurred with the current state of the resource."
            case .payloadTooLarge: return "The payload is too large to process."
            case .unsupportedMediaType: return "The media type is not supported by the server."
            case .tooManyRequests: return "Too many requests have been sent in a short time. Try again later."
            case .serverError: return "An internal server error occurred."
            case .serviceUnavailable: return "The service is temporarily unavailable."
            case .gatewayTimeout: return "The server gateway timed out while waiting for a response."
                
            case .noDataReceived: return "No data was received from the request."
            case .invalidResponse: return "The response received was invalid."
            case .parsingFailed: return "Failed to parse the data."
            case .dataCorruption: return "The data received is corrupted."
            case .jsonDecodingFailed: return "Failed to decode JSON data."
            case .xmlParsingFailed: return "Failed to parse XML data."
                
            case .invalidReleaseFormat: return "The release format is invalid or not supported."
            case .releaseNotFound: return "No release was found for the specified criteria."
            case .incompatibleUpdate: return "The update is not compatible with the current version."
            case .updateFailed: return "The update process failed."
            case .updateAlreadyInProgress: return "An update process is already in progress."
            case .updateCancelled: return "The update process was cancelled."
            case .insufficientPermissions: return "Insufficient permissions to perform the update."
            case .updateChecksumMismatch: return "The update checksum does not match."
            case .updateFileNotFound: return "The update file could not be found."
                
            case .missingCredentials: return "Missing credentials. Please provide the required authentication details."
            case .invalidToken: return "The authentication token is invalid."
            case .tokenExpired: return "The authentication token has expired."
            case .accessRevoked: return "Access has been revoked. Please reauthenticate."
            case .captchaRequired: return "A CAPTCHA is required to proceed."
                
            case .fileNotFound: return "The specified file could not be found."
            case .insufficientStorage: return "There is not enough storage space available."
            case .writeFailed: return "Failed to write data to the file system."
            case .readFailed: return "Failed to read data from the file system."
            case .permissionDenied: return "Permission denied to access the file system."
                
            case .missingConfiguration: return "A required configuration is missing."
            case .invalidConfiguration: return "The configuration provided is invalid."
            case .featureNotSupported: return "The requested feature is not supported."
                
            case .unknown: return "An unknown error occurred."
            case .operationCancelled: return "The operation was cancelled."
            case .invalidState: return "The system is in an invalid state to perform this operation."
            case .dependencyUnavailable: return "A required dependency is unavailable."
            }
        }
    }
    
    public init(
        domain: String,
        code: SUKErrorCode,
        userInfo: [String: String]? = nil
    ) {
        self.domain = domain
        self.code = code
        var finalUserInfo = userInfo ?? [:]
        finalUserInfo["description"] = code.description
        self.userInfo = finalUserInfo
    }
}
