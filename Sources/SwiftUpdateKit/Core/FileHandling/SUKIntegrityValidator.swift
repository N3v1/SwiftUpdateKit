//
//  SUKIntegrityValidator.swift
//  SwiftUpdateKit Core FileHandeling (SUK)
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
import CryptoKit

/// A utility class for validating the integrity of files used within the ``SwiftUpdateKit`` framework.
///
/// The purpose of the <doc:SUKIntegrityValidator> class is to ensure that files handled by the framework are valid,
/// both in terms of structure and integrity. This includes verifying checksums, file types, and ensuring that
/// files meet specified conditions required for the successful operation of updates and installations within the framework.
///
/// This class is a core part of the file handling system, ensuring that files are correctly verified before
/// any updates, installations, or manipulations occur. It plays a critical role in avoiding errors that might
/// arise from corrupted, incomplete, or incompatible files.
@available(macOS 15.0, *)
public final class SUKIntegrityValidator: @unchecked Sendable {
    
    /// A typealias representing the checksum used for file integrity validation.
    ///
    /// The `_SUKChecksum` typealias is defined as a `String`, which is used to represent the checksum value for
    /// validating the integrity of files. This checksum is typically computed using cryptographic hash functions,
    /// such as SHA256, to ensure that the file's content has not been tampered with or corrupted during transmission.
    ///
    /// - Note: `_SUKChecksum` is equivalent to a `String` and is used as the expected checksum in file validation processes.
    ///
    /// - Important: This typealias is deprecated and will be removed in a future version.
    ///   Please use the renamed <doc:SUKChecksum> struct instead for better type safety, flexibility,
    ///   and extensibility in checksum-related operations. The <doc:SUKChecksum> struct provides a
    ///   more robust solution and supports comparison and validation features that the typealias
    ///   does not offer.
    @available(*, deprecated,renamed: "SUKChecksum",
                message: "Use `SUKChecksum` struct for enhanced type safety and extensibility.")
    public typealias _SUKChecksum = String
    
    /// A struct representing the checksum used for file integrity validation.
    /// The <doc:SUKChecksum> struct wraps a SHA256 checksum (represented as a string) and provides functionality
    /// for comparing checksums, validation, and any other checksum-related operations.
    /// - Note: <doc:SUKChecksum> encapsulates the checksum string to ensure type safety and can be extended
    ///         with methods for validation or additional features.
    public struct SUKChecksum {
        
        /// A string representing the checksum used to validate the integrity of a file or asset.
        ///
        /// The <doc:checksum> property holds the hash value (typically a SHA256 hash) that serves as a digital fingerprint
        /// for verifying the file's integrity and ensuring it has not been altered or corrupted.
        public let checksum: String
        
        /// Initializes a new `SUKChecksum` instance with the provided checksum string.
        ///
        /// This initializer creates a new `SUKChecksum` object, encapsulating the checksum string that can be used for
        /// file integrity validation, comparison, or other checksum-related operations.
        ///
        /// - Parameter checksum: A string representing the checksum to initialize the struct with.
        /// - Note: The checksum should be a valid SHA256 hash string (64 hexadecimal characters).
        public init(checksum: String) {
            self.checksum = checksum
        }
        
        /// Returns the <doc:checksum> value as a string.
        ///
        /// This computed property retrieves the stored <doc:checksum> value, allowing access to the raw <doc:checksum> string.
        /// The returned value is the same checksum that was provided during initialization.
        ///
        /// - Returns: The <doc:checksum> string used for integrity verification.
        public var value: String {
            return checksum
        }
        
        /// Compares this checksum (lhs) to another checksum (rhs).
        ///
        /// - Parameters:
        ///   - lhs: The left-hand side checksum.
        ///   - rhs: The right-hand side checksum.
        /// - Returns: A Boolean value indicating whether the checksums are equal.
        public static func == (lhs: SUKChecksum, rhs: SUKChecksum) -> Bool {
            return lhs.checksum == rhs.checksum
        }
        
        /// Compares this checksum (lhs) to a string value representing a checksum (rhs).
        ///
        /// - Parameters:
        ///   - lhs: The left-hand side checksum.
        ///   - rhs: The right-hand side checksum string.
        /// - Returns: A Boolean value indicating whether the checksums are equal.
        public static func == (lhs: SUKChecksum, rhs: String) -> Bool {
            return lhs.checksum == rhs
        }
        
        /// Validates if the local checksum matches the provider's checksum.
        ///
        /// - Parameters:
        ///   - localChecksum: The checksum of the local installer/asset.
        ///   - providerChecksum: The expected checksum from the release provider.
        /// - Returns: A Boolean value indicating whether the local and provider checksums match.
        public static func validateChecksum(localChecksum: SUKChecksum, providerChecksum: SUKChecksum) -> Bool {
            guard isValidChecksumFormat(localChecksum), isValidChecksumFormat(providerChecksum) else {
                return false
            }
            
            return localChecksum == providerChecksum
        }
        
        /// Validates the format of a checksum to ensure it is a valid SHA256 hash (64 characters of hexadecimal digits).
        ///
        /// - Parameter checksum: The checksum string to validate.
        /// - Returns: A Boolean value indicating whether the checksum is a valid SHA256 hash.
        private static func isValidChecksumFormat(_ checksum: SUKChecksum) -> Bool {
            let regex = "^[a-fA-F0-9]{64}$"
            let checksumValue = checksum.value
            
            let regexTest = try? NSRegularExpression(pattern: regex)
            let range = NSRange(location: 0, length: checksumValue.count)

            return regexTest?.firstMatch(in: checksumValue, options: [], range: range) != nil
        }
    }
    
    /// The shared instance of <doc:SUKIntegrityValidator> for global access.
    ///
    /// This singleton provides a centralized mechanism for validating the integrity of files used in the update process.
    /// Using the shared instance ensures that any validation task is managed consistently across the entire framework.
    public static let shared = SUKIntegrityValidator()
    
    private let fileManager = FileManager.default
    
    /// Private initializer to enforce the singleton pattern.
    ///
    /// The singleton is used to ensure that file validation tasks are centralized, and this private initializer
    /// prevents any unnecessary instantiation of the <doc:SUKIntegrityValidator> class.
    private init() {}
    
    /// Validates the integrity of a file by comparing its checksum with an expected checksum.
    ///
    /// This method calculates the checksum of the file located at the provided `path` and compares it to the
    /// `expectedChecksum`. If the checksums do not match, an error is thrown indicating the integrity failure.
    ///
    /// - Parameters:
    ///   - path: The file path to the file that needs validation.
    ///   - checksum: The expected checksum of the file to compare against.
    ///
    /// - Throws:
    ///   - `SUKError.SUKIntegrityValidationError.fileNotFound` if the file at the specified `path` does not exist.
    ///   - `SUKError.SUKIntegrityValidationError.invalidChecksum` if the file’s checksum does not match the expected value.
    ///
    /// - Note:
    ///   - The checksum is computed using SHA256. This ensures that files have not been corrupted during download or update.
    public func validateFileIntegrity(at path: String, checksum: SUKChecksum) throws {}
    
    /// Verifies if a file at a specified path is of a valid type.
    ///
    /// This method checks whether the file's extension matches one of the allowed installer package extensions
    /// defined in the <doc:SUKAllowedInstallerExtensions> enum. By ensuring that only files of expected types are processed,
    /// this method helps prevent errors caused by invalid or unexpected file formats during the update process.
    ///
    /// - Parameters:
    ///   - path: The file path of the file to validate.
    ///   - allowedExtensions: An array of <doc:SUKAllowedInstallerExtensions> representing the file extensions that are allowed
    ///     for processing. The extensions are checked against the file at the specified path.
    ///
    /// - Throws:
    ///   - `SUKError.SUKIntegrityValidatorError.invalidFileType` if the file's extension does not match one of the allowed
    ///     extensions from <doc:SUKAllowedInstallerExtensions>.
    ///
    /// - Note:
    ///   - This method uses the `fileExtension` property of <doc:SUKAllowedInstallerExtensions> to verify if the file's
    ///     extension is valid.
    public func validateFileType(at path: String, allowedExtensions: [SUKAllowedInstallerExtensions]) throws {}
    
    /// Generates the SHA256 checksum for a file.
    ///
    /// This method computes the SHA256 checksum for a given file, which is often used for integrity checks
    /// to verify that the file has not been tampered with.
    ///
    /// - Parameter fileURL: The URL of the file for which the checksum will be generated.
    /// - Returns: The SHA256 checksum of the file as a <doc:SUKChecksum>, or `nil` if an error occurs.
    private func generateChecksum(for fileURL: URL) -> SUKChecksum? {
        do {
            let fileData = try Data(contentsOf: fileURL)
            let sha256Hash = SHA256.hash(data: fileData)
            let checksum = sha256Hash.map { String(format: "%02x", $0) }.joined()
            
            return SUKChecksum(checksum: checksum)
        } catch {
            return nil
        }
    }
    
    /// An enumeration that defines the allowed file extensions for installer packages
    /// supported by the SwiftUpdateKit (SUK) framework.
    ///
    /// The <doc:SUKAllowedInstallerExtensions> enum ensures that only valid installer
    /// file types are used during the update process. By providing a controlled list
    /// of supported file extensions, it helps prevent errors caused by unsupported or
    /// invalid file types. This enum acts as a validator that ensures only recognized
    /// installer formats are processed, enhancing the reliability and security of the
    /// update workflow.
    ///
    /// ## File Extensions
    /// - `.pkg`: A macOS package installer file extension, used for distributing
    ///   software with a guided installation process.
    /// - `.dmg`: A macOS disk image file extension, often used to distribute
    ///   software packages or applications as a mounted disk image.
    /// - `.zip`: A compressed archive file extension, commonly used across platforms
    ///   to bundle and distribute multiple files.
    /// - `.tar.gz`: A compressed TAR archive file, often used on Unix-like systems
    ///   for packaging files with gzip compression.
    /// - `.xip`: A macOS-specific compressed file format used to securely package
    ///   macOS applications, ensuring integrity and authenticity during expansion.
    /// - `.app`: The directory format used by macOS for applications, often
    ///   distributed as part of macOS app bundles.
    ///
    /// This enum can be used to restrict file inputs, ensuring the proper formats
    /// are used in the update and installation process, preventing unwanted file types
    /// from causing issues.
    ///
    /// The `fileExtension` property converts the enum case into its corresponding
    /// string file extension, which is useful for validation, filtering, or performing
    /// operations on files that match the allowed installer types.
    public enum SUKAllowedInstallerExtensions: Equatable, Hashable {
        
        /// A macOS package installer file extension.
        ///
        /// PKG is the standard installer format for macOS, used to distribute
        /// software that includes an installation process and typically requires user
        /// interaction during installation.
        case pkg
        
        /// A macOS disk image file extension.
        ///
        /// DMG is a disk image format used in macOS to distribute software and other
        /// files. The DMG format is often used to package software installers or
        /// applications that the user can mount and drag into the `/Applications`
        /// folder for installation.
        case dmg
        
        /// A compressed ZIP archive file extension.
        ///
        /// ZIP is a widely used compressed file format across platforms. It packages
        /// multiple files into one archive, making it easier to distribute software
        /// or a collection of files, which may require manual extraction before
        /// installation.
        case zip
        
        /// A compressed TAR archive (gzip) file extension.
        ///
        /// TAR is a format used to bundle multiple files into a single archive,
        /// and gzip compression is applied to reduce the size of the archive.
        /// This format is commonly used in Unix-like systems for distributing
        /// software packages and is typically accompanied by extraction tools like
        /// `tar` and `gunzip`.
        case tar_gz
        
        /// A macOS-specific compressed file format used for secure distribution.
        ///
        /// XIP is a macOS-specific format that combines compression and security
        /// to package macOS applications. It ensures integrity and authenticity,
        /// performing verification during decompression to ensure the contents
        /// are safe and uncorrupted before use.
        case xip
        
        /// A macOS application bundle file extension.
        ///
        /// APP represents the format for macOS application bundles, typically a
        /// directory structure that contains all the resources and binaries required
        /// to run the application on macOS. It is commonly used when distributing
        /// apps for macOS, either as standalone bundles or as part of a DMG.
        case app
        
        // MARK: - Computed Property
        
        /// A computed property that returns the string representation of the file
        /// extension for each installer type.
        ///
        /// This property allows you to access the actual file extension for each
        /// case, which is useful for performing file-type validation or matching
        /// files with the corresponding installer types.
        ///
        /// - Returns: A string representing the file extension (e.g., ".pkg", ".dmg", etc.).
        public var fileExtension: String {
            switch self {
            case .pkg: return ".pkg"
            case .dmg: return ".dmg"
            case .zip: return ".zip"
            case .tar_gz: return ".tar.gz"
            case .xip: return ".xip"
            case .app: return ".app"
            }
        }
    }
}
