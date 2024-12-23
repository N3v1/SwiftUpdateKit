//
//  SUKFileManager.swift
//  SwiftUpdateKit Core FileHandling (SUK)
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
public extension SUKError {
    
    /// A collection of error types used by `SUKFileManager` for handling various file
    /// system operations.
    ///
    /// These errors capture common issues encountered during file operations, such as
    /// missing files, permission issues, or problems encountered during reading, writing,
    /// or moving files.
    @available(macOS 15.0, *)
    enum SUKFileManagerError: Error {
        
        /// Raised when the requested file does not exist at the specified path.
        case fileNotFound
        
        /// Raised when the provided file or directory path is malformed or invalid.
        case invalidPath
        
        /// Raised when the creation of a new directory fails.
        case directoryCreationFailed
        
        /// Raised when an error occurs while attempting to write data to a file.
        case fileWriteFailed
        
        /// Raised when an error occurs while attempting to read data from a file.
        case fileReadFailed
        
        /// Raised when a file or directory already exists at the specified path, preventing the operation.
        case fileAlreadyExists
        
        /// Raised when the file extension does not match the allowed file types.
        case invalidFileType
        
        /// A generic error that wraps any other underlying error encountered during file operations.
        case operationFailed(Error)
    }
}

/// A class that provides utility methods for managing files and directories.
///
/// `SUKFileManager` simplifies the management of file operations such as reading, writing,
/// copying, and moving files within the file system. It provides both synchronous and asynchronous
/// methods to handle various file system tasks.
///
/// - Note: The `SUKFileManager` is designed as a singleton to ensure consistent file management
///         across your app. To access the instance, use the shared `SUKFileManager.shared` property.
@available(macOS 15.0, *)
public class SUKFileManager: @unchecked Sendable {
    // MARK: - Singleton
    
    /// The shared instance of `SUKFileManager`.
    ///
    /// This singleton allows for consistent file management across the application. It is used to perform
    /// all file system operations. You should always use `SUKFileManager.shared` instead of creating new instances.
    public static let shared = SUKFileManager()
    
    // MARK: - Private Properties
    
    /// The `FileManager` instance used for interacting with the file system.
    private let fileManager = FileManager.default
    
    // MARK: - Initialization
    
    /// Private initializer to ensure that only a single instance of `SUKFileManager` is created.
    ///
    /// This design pattern ensures that `SUKFileManager` remains a singleton, and its methods are called from the shared instance.
    private init() {}
    
    // MARK: - File Handling Methods (FSK)
    
    /// Creates a directory at the specified path.
    ///
    /// This method checks if the directory already exists, and if not, attempts to create it. If the directory creation fails,
    /// an error is thrown. If `withIntermediateDirectories` is set to `true`, it will also create any necessary intermediate directories.
    ///
    /// - Parameter path: The full path where the directory should be created.
    /// - Parameter withIntermediateDirectories: A flag that determines whether intermediate directories should be created if they do not exist.
    /// - Throws: `SUKFileManagerError.fileAlreadyExists` if the directory already exists.
    /// - Throws: `SUKFileManagerError.directoryCreationFailed` if the directory creation fails.
    public func createDirectory(at path: String, withIntermediateDirectories: Bool = true) throws {
        guard !fileExists(at: path) else {
            throw SUKError.SUKFileManagerError.fileAlreadyExists
        }
        
        do {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: withIntermediateDirectories, attributes: nil)
        } catch {
            throw SUKError.SUKFileManagerError.directoryCreationFailed
        }
    }
    
    /// Removes a file or directory at the specified path.
    ///
    /// This method checks if the file or directory exists at the given path and deletes it. If the file does not exist or if an
    /// error occurs during the removal, an error is thrown.
    ///
    /// - Parameter path: The path of the file or directory to remove.
    /// - Throws: `SUKFileManagerError.fileNotFound` if the file does not exist.
    /// - Throws: `SUKFileManagerError.operationFailed` if an error occurs during the operation.
    public func removeFile(at path: String) throws {
        guard fileExists(at: path) else {
            throw SUKError.SUKFileManagerError.fileNotFound
        }
        
        do {
            try fileManager.removeItem(atPath: path)
        } catch {
            throw SUKError.SUKFileManagerError.operationFailed(error)
        }
    }
    
    /// Copies a file from the source path to the destination path.
    ///
    /// This method first checks if the file exists at the source path and then copies it to the destination path. If `versioned` is `true`,
    /// a backup copy of the destination file will be created before the copy operation.
    ///
    /// - Parameter source: The path of the source file.
    /// - Parameter destination: The path of the destination file.
    /// - Parameter versioned: A flag indicating whether the destination file should be versioned (backed up with a timestamp).
    /// - Throws: `SUKFileManagerError.fileNotFound` if the source file does not exist.
    /// - Throws: `SUKFileManagerError.operationFailed` if an error occurs during the copy operation.
    public func copyFile(from source: String, to destination: String, versioned: Bool = false) throws {
        guard fileExists(at: source) else {
            throw SUKError.SUKFileManagerError.fileNotFound
        }
        
        if versioned {
            let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
            let backupPath = destination + ".backup-\(timestamp)"
            try moveFile(from: destination, to: backupPath)
        }
        
        do {
            try fileManager.copyItem(atPath: source, toPath: destination)
        } catch {
            throw SUKError.SUKFileManagerError.operationFailed(error)
        }
    }
    
    /// Moves a file from the source path to the destination path.
    ///
    /// This method checks if the source file exists and then moves it to the destination path. If an error occurs during the move operation,
    /// it is thrown to the caller.
    ///
    /// - Parameter source: The path of the source file.
    /// - Parameter destination: The path of the destination file.
    /// - Throws: `SUKFileManagerError.fileNotFound` if the source file does not exist.
    /// - Throws: `SUKFileManagerError.operationFailed` if an error occurs during the move operation.
    public func moveFile(from source: String, to destination: String) throws {
        guard fileExists(at: source) else {
            throw SUKError.SUKFileManagerError.fileNotFound
        }
        
        do {
            try fileManager.moveItem(atPath: source, toPath: destination)
        } catch {
            throw SUKError.SUKFileManagerError.operationFailed(error)
        }
    }
    
    /// Checks if a file or directory exists at the specified path.
    ///
    /// This method returns `true` if the file or directory exists at the specified path, and `false` otherwise.
    ///
    /// - Parameter path: The path to check.
    /// - Returns: A boolean indicating whether the file or directory exists at the given path.
    public func fileExists(at path: String) -> Bool {
        return fileManager.fileExists(atPath: path)
    }
    
    /// Retrieves the contents of a directory at the specified path.
    ///
    /// This method returns an array of strings representing the contents of the directory at the given path.
    /// It throws an error if the operation fails (e.g., the directory does not exist or cannot be read).
    ///
    /// - Parameter path: The path of the directory to retrieve contents from.
    /// - Returns: An array of strings representing the contents of the directory.
    /// - Throws: `SUKFileManagerError.operationFailed` if the operation fails.
    public func contentsOfDirectory(at path: String) throws -> [String] {
        do {
            return try fileManager.contentsOfDirectory(atPath: path)
        } catch {
            throw SUKError.SUKFileManagerError.operationFailed(error)
        }
    }
    
    /// Reads a file at the given path and decodes it into a specified type.
    ///
    /// This method reads the content of the file at the provided path and decodes it into the specified `Decodable` type.
    /// It throws an error if the file does not exist, or if the data cannot be decoded into the desired type.
    ///
    /// - Parameter path: The path to the file to read.
    /// - Parameter type: The `Decodable` type to decode the file into.
    /// - Returns: An instance of the decoded object.
    /// - Throws: `SUKFileManagerError.fileNotFound` if the file does not exist.
    /// - Throws: `SUKFileManagerError.fileReadFailed` if the file cannot be read or decoded.
    public func readFile<T: Decodable>(at path: String, as type: T.Type) throws -> T {
        guard fileExists(at: path) else {
            throw SUKError.SUKFileManagerError.fileNotFound
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            let object = try decoder.decode(T.self, from: data)
            return object
        } catch {
            throw SUKError.SUKFileManagerError.fileReadFailed
        }
    }
    
    /// Writes data to a file at the specified path.
    ///
    /// This method encodes the provided data and writes it to the specified file. It throws an error if the file cannot be written to
    /// (e.g., due to insufficient permissions or other IO issues).
    ///
    /// - Parameter path: The path where the data should be written.
    /// - Parameter data: The `Encodable` data to write to the file.
    /// - Throws: `SUKFileManagerError.fileWriteFailed` if the file cannot be written.
    public func writeFile<T: Encodable>(at path: String, data: T) throws {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(data)
            try encodedData.write(to: URL(fileURLWithPath: path))
        } catch {
            throw SUKError.SUKFileManagerError.fileWriteFailed
        }
    }
    
    /// Validates that a file's extension is within the allowed types.
    ///
    /// This method checks if the file's extension matches one of the allowed types. If the extension is invalid,
    /// it throws an error.
    ///
    /// - Parameter path: The path of the file to validate.
    /// - Parameter allowedExtensions: An array of valid file extensions.
    /// - Throws: `SUKFileManagerError.invalidFileType` if the file's extension is not allowed.
    public func validateFile(at path: String, allowedExtensions: [String]) throws {
        let fileExtension = URL(fileURLWithPath: path).pathExtension.lowercased()
        
        if fileExtension.isEmpty {
            throw SUKError.SUKFileManagerError.invalidFileType
        }
        
        if !allowedExtensions.contains(fileExtension) {
            throw SUKError.SUKFileManagerError.invalidFileType
        }
    }
    
    /// Asynchronously removes a file at the specified path.
    ///
    /// This method performs the `removeFile(at:)` operation asynchronously on a background queue. It uses a completion handler
    /// to notify the caller about the result of the operation.
    ///
    /// - Parameter path: The path of the file to remove.
    /// - Parameter completion: A closure that will be called with the result of the operation. It contains either a `success` or a `failure`.
    public func removeFileAsync(at path: String, completion: @Sendable @escaping (Result<Void, SUKError.SUKFileManagerError>) -> Void) {
        DispatchQueue.global().async {
            do {
                try self.removeFile(at: path)
                completion(.success(()))
            } catch let error as SUKError.SUKFileManagerError {
                completion(.failure(error))
            } catch {
                completion(.failure(.operationFailed(error)))
            }
        }
    }
}
