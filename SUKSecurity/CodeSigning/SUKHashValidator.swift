//
//  SUKHashValidator.swift
//  SwiftUpdateKit Security CodeSigning (SUK)
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

/// A utility extension for the <doc:SUKIntegrityValidator> class, which enables the calculation, validation,
/// and verification of file integrity using SHA-256 hash values. This extension is particularly useful
/// for ensuring that a file has not been tampered with or corrupted during software updates or any
/// other file integrity checks.
///
/// The core purpose of this extension is to compute cryptographically secure hash values for files,
/// compare them to expected hash values, and verify if files are intact. This process is crucial in
/// maintaining the security and trustworthiness of software, ensuring that users receive genuine,
/// untampered files when performing updates or downloading software.
@available(macOS 15.0, *)
public extension SUKIntegrityValidator {
    
    /// A struct that encapsulates a SHA-256 hash value computed from a file, which is used for comparing
    /// the integrity of files against expected hash values.
    ///
    /// This struct is at the heart of file integrity validation, providing a secure way to represent
    /// a hash value and allowing comparisons between computed hash values and expected values.
    /// By using this struct, developers can easily integrate file integrity checks into their
    /// applications, ensuring that files remain unchanged and valid over time.
    ///
    /// - Note: The hash value stored in this struct is always expected to be a valid 64-character
    ///   hexadecimal string representing a SHA-256 hash.
    @available(macOS 15.0, *)
    struct SUKIntegrityHash {
        
        private let hashValue: String
        
        /// Initializes a new instance of the `SUKIntegrityHash` struct using a provided hash value.
        ///
        /// This initializer allows the creation of a `SUKIntegrityHash` instance using a SHA-256 hash value
        /// (a 64-character hexadecimal string). This value is typically computed from the contents of a file.
        ///
        /// - Parameter hashValue: A string representing the SHA-256 hash of a file. This must be a valid
        ///   hexadecimal string of 64 characters.
        ///
        /// - Precondition: The `hashValue` must be a valid SHA-256 hash string. If the string does not
        ///   conform to the correct format, errors could occur during validation or comparison.
        public init(hashValue: String) {
            self.hashValue = hashValue
        }
        
        /// The raw hash value of the file, represented as a string.
        ///
        /// This computed property returns the hash value stored in the struct. It is the 64-character
        /// hexadecimal string representing the computed SHA-256 hash of a file. This is the value used
        /// for comparison, verification, and validation of file integrity.
        ///
        /// - Returns: A string representing the computed SHA-256 hash of the file.
        public var value: String {
            return hashValue
        }
        
        /// Compares two `SUKIntegrityHash` instances for equality, based on their stored hash values.
        ///
        /// This method is used to compare the hash values of two `SUKIntegrityHash` instances to determine
        /// whether they represent the same hash. This is important in scenarios where you need to verify
        /// that two files are identical or that a file's content matches a known and expected hash.
        ///
        /// - Parameters:
        ///   - lhs: The left-hand side `SUKIntegrityHash` instance.
        ///   - rhs: The right-hand side `SUKIntegrityHash` instance.
        ///
        /// - Returns: A Boolean value indicating whether the hash values of both instances are identical.
        ///   `true` if the hash values are the same, otherwise `false`.
        public static func == (lhs: SUKIntegrityHash, rhs: SUKIntegrityHash) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }

        /// Compares a `SUKIntegrityHash` instance to a raw hash string to determine equality.
        ///
        /// This method provides an easy way to compare the hash value stored in a `SUKIntegrityHash` instance
        /// to a raw hash string, which is typically a SHA-256 hash string obtained from an external source
        /// (e.g., a remote server or a trusted party).
        ///
        /// - Parameters:
        ///   - lhs: The `SUKIntegrityHash` instance containing the hash value to be compared.
        ///   - rhs: The raw hash string to compare with the `SUKIntegrityHash`.
        ///
        /// - Returns: A Boolean value indicating whether the `SUKIntegrityHash` instance's hash value
        ///   matches the provided string. `true` if they match, otherwise `false`.
        public static func == (lhs: SUKIntegrityHash, rhs: String) -> Bool {
            return lhs.hashValue == rhs
        }

        /// Validates whether a computed hash value matches the expected hash value.
        ///
        /// This static method is used to validate the integrity of a file by comparing the locally computed
        /// hash with the expected hash value. This is critical in scenarios such as software updates,
        /// where you want to ensure that the file being downloaded or installed has not been tampered with
        /// or altered during transmission.
        ///
        /// - Parameters:
        ///   - localHash: The hash computed from the local file that needs to be validated.
        ///   - expectedHash: The expected hash value that the `localHash` should match.
        ///
        /// - Returns: A Boolean value indicating whether the `localHash` is equal to the `expectedHash`.
        ///   Returns `true` if the hashes match, `false` otherwise.
        public static func validate(localHash: SUKIntegrityHash, expectedHash: SUKIntegrityHash) -> Bool {
            return localHash == expectedHash
        }

        /// Verifies that the given hash value is in the correct format (64-character hexadecimal string).
        ///
        /// This private helper function checks whether the hash value conforms to the expected format for
        /// SHA-256 hashes, which are 64-character strings consisting of hexadecimal digits (0-9, a-f).
        /// The hash format is validated using a regular expression to ensure that the string is valid
        /// and can safely be used in cryptographic operations.
        ///
        /// - Parameter hash: The hash to validate.
        ///
        /// - Returns: A Boolean value indicating whether the hash value is in the correct format.
        ///   Returns `true` if the hash is valid, `false` otherwise.
        private static func isValidFormat(_ hash: SUKIntegrityHash) -> Bool {
            let regex = "^[a-fA-F0-9]{64}$"
            
            let regexTest = try? NSRegularExpression(pattern: regex)
            let range = NSRange(location: 0, length: hash.hashValue.count)
            return regexTest?.firstMatch(in: hash.hashValue, options: [], range: range) != nil
        }
        
        /// Calculates the SHA-256 hash for a file located at the provided URL.
        ///
        /// This method computes the SHA-256 hash of a file by reading its contents from disk, performing
        /// the cryptographic hash computation, and returning the resulting hash as a `SUKIntegrityHash` instance.
        /// This operation is fundamental for ensuring that the file's integrity can be checked against an
        /// expected hash value.
        ///
        /// - Parameters:
        ///   - fileURL: The URL of the file to compute the hash for. This could be a local file URL
        ///              pointing to any file on disk that needs to be validated.
        ///   - algorithm: The hash algorithm to use (default is SHA-256).
        ///
        /// - Throws: An error if the file cannot be read, or if an issue occurs during the hash computation.
        ///
        /// - Returns: A `SUKIntegrityHash` instance that encapsulates the computed SHA-256 hash of the file.
        ///   This hash can then be used for integrity checks or comparisons.
        public static func calculateHash(forFileAt fileURL: URL, algorithm: SUKHashAlgorithm = .sha256) throws -> SUKIntegrityHash {
            let fileData = try Data(contentsOf: fileURL)
            let hash: Data
            
            switch algorithm {
            case .sha224:
                let sha256Digest = SHA256.hash(data: fileData)
                hash = Data(sha256Digest.prefix(28))
            case .sha256:
                let sha256Digest = SHA256.hash(data: fileData)
                hash = Data(sha256Digest)
            case .sha384:
                let sha384Digest = SHA384.hash(data: fileData)
                hash = Data(sha384Digest)
            case .sha512:
                let sha512Digest = SHA512.hash(data: fileData)
                hash = Data(sha512Digest)
            case .blake2:
                throw NSError(domain: "SUKIntegrityHashError", code: -2021, userInfo: [NSLocalizedDescriptionKey: "BLAKE2 not supported"])
            }
            
            let hexString = hash.map { String(format: "%02x", $0) }.joined()
            return SUKIntegrityHash(hashValue: hexString)
        }
        
        /// Verifies the integrity of a file by comparing its computed hash with an expected hash.
        ///
        /// This method is used to ensure that a file has not been tampered with by comparing the computed
        /// hash of the file with an expected hash value. If the hashes match, the file is considered to
        /// have maintained its integrity. This is an essential process in maintaining secure software systems
        /// and preventing malicious tampering or data corruption.
        ///
        /// - Parameters:
        ///   - fileURL: The URL of the file to verify.
        ///   - expectedHash: The hash value that the computed hash of the file should match.
        ///
        /// - Throws: An error if the file cannot be read, or if the hash computation fails.
        ///
        /// - Returns: A Boolean value indicating whether the file's integrity is valid. Returns `true` if
        ///   the computed hash matches the expected hash, and `false` if it does not.
        public static func verifyFileIntegrity(forFileAt fileURL: URL, expectedHash: SUKIntegrityHash) throws -> Bool {
            let computedHash = try calculateHash(forFileAt: fileURL)
            return validate(localHash: computedHash, expectedHash: expectedHash)
        }
        
        /// An enumeration that represents the available cryptographic hash algorithms
        /// that can be used for hashing data, such as files or strings.
        ///
        /// This enum supports multiple hashing algorithms, which can be selected based
        /// on the specific needs for cryptographic integrity checks.
        public enum SUKHashAlgorithm {
            
            /// SHA-224 is a variant of SHA-256 that produces a 224-bit hash.
            ///
            /// It is part of the SHA-2 family and is used in situations where a smaller hash value is preferred but still offers
            /// strong security, though SHA-256 is more commonly used in most cases.
            case sha224
            
            /// SHA-256 (Secure Hash Algorithm 256-bit) is part of the SHA-2 family and produces a 256-bit hash.
            ///
            /// It is a cryptographically secure hash function that is widely used in various
            /// applications, including blockchain, certificate generation, and digital signatures.
            ///
            /// When using this algorithm, the resulting hash is 32 bytes long (256 bits).
            case sha256
            
            /// SHA-384 is a variant of SHA-512 that produces a 384-bit hash.
            ///
            /// SHA-384 offers a higher degree of security than SHA-256 while providing a smaller hash output than SHA-512.
            case sha384
            
            /// SHA-512 (Secure Hash Algorithm 512-bit) is another member of the SHA-2 family and produces a 512-bit hash.
            ///
            /// This algorithm is often used when a higher degree of security is required. It generates a longer hash than SHA-256,
            /// which can provide increased resistance to certain types of attacks. SHA-512 produces a 64-byte (512-bit) hash.
            case sha512
            
            /// BLAKE2 is a cryptographic hash function designed as an alternative to MD5 and SHA-2.
            ///
            /// It is faster than both MD5 and SHA-2, and it provides a high level of security. It is often used in scenarios where
            /// speed is critical, such as in file integrity verification or cryptographic operations that require performance.
            ///
            /// - Important: BLAKE2 is not supported on all platforms, and additional third-party libraries may be required to use it.
            @available(macOS, unavailable, message: "BLAKE2 is not supported. Please use SHA algorithms.")
            case blake2
        }
    }
}
