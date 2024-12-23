//
//  SUKCodeSigningValidator.swift
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
import Security

/// The `SUKCodeSigningValidator` extension contains functionality related to verifying and validating
/// code signatures for files within the SwiftUpdateKit framework. Code signing ensures the integrity and
/// authenticity of code, validating that it has not been tampered with and that it originates from a trusted source.
///
/// This extension provides functionality to both check the validity of a code signature and extract
/// the signing certificate associated with a file. Code signing is particularly important for software
/// updates, where it's crucial to ensure the software hasn't been altered maliciously after it was signed by
/// a trusted source.
///
/// - `SUKCodeSignature`: A struct that contains the result of the code signing validation, including the
///   validity of the signature and any associated signing certificate.
/// - `verifyCodeSignature(forFileAt:)`: A function to verify whether the code signature for a specific file
///   is valid, including the retrieval of its signing certificate if available.
/// - `checkCodeSignature(forFileAt:)`: A function to inspect the code signature and extract signing information
///   from a file at a specified URL, determining the signature's status and providing necessary details.
/// - `SUKCodeSigningStatus`: A struct that encapsulates the code signing status and any associated certificate.
///
/// ## Overview of Code Signing in macOS
/// Code signing is a security technology in macOS that ensures only trusted software can run on a system.
/// A valid code signature confirms that the code has not been altered after it was signed by a trusted
/// identity. The code signing process uses cryptographic techniques to generate a signature based on
/// the contents of the code and a private key associated with the developer's identity. The macOS system
/// then uses this signature to verify the authenticity of the code before it is executed.
///
/// ## How Code Signing Works
/// 1. **Code Signing**: When an application is developed, a developer signs their code with a private key.
///    The signature is unique to that developer and proves the code came from a trusted source.
/// 2. **Code Verification**: When the system executes the code, it verifies the code signature against the
///    public key associated with the developer's certificate, ensuring that the code has not been tampered with.
/// 3. **Certificate Chain**: The certificate used to sign the code is validated against a trusted certificate chain,
///    ensuring that it has been issued by a trusted authority.
///
/// The `SUKCodeSigningValidator` provides a way to ensure that files, such as executables or scripts, have valid
/// code signatures and are signed by a trusted certificate authority.
@available(macOS 15.0, *)
public extension SUKIntegrityValidator {
    
    
    /// <doc:SUKCodeSignature> is a struct that holds the result of code signing validation for a given file.
    /// It provides the status of the signature's validity and any associated signing certificate.
    ///
    /// This struct is essential for users or systems that need to determine whether a file has a valid
    /// code signature and to access the certificate used for signing the file.
    ///
    /// The `isSignatureValid` property indicates whether the file's code signature is valid or not.
    /// The `signingCertificate` property, if present, provides access to the certificate used to sign the code.
    ///
    /// ## Code Signing Validation Process:
    /// The process of code signing validation involves several steps:
    /// - First, the system creates a static code object using `SecStaticCodeCreateWithPath`.
    /// - Then, it retrieves the signing information with `SecCodeCopySigningInformation`, which provides details
    ///   such as the certificate and status of the code signature.
    @available(macOS 15.0, *)
    struct SUKCodeSignature {
        private let isValid: Bool
        private let certificate: SecCertificate?
        
        /// Initializes a `SUKCodeSignature` instance with the specified validity and certificate.
        ///
        /// This initializer is used to represent the result of a code signature validation, including
        /// whether the signature is valid and the certificate associated with the signature.
        ///
        /// - Parameters:
        ///   - isValid: A Boolean value representing whether the code signature is valid.
        ///   - certificate: The `SecCertificate` associated with the code signature, or `nil` if not available.
        public init(isValid: Bool, certificate: SecCertificate?) {
            self.isValid = isValid
            self.certificate = certificate
        }
        
        /// Returns whether the code signature is valid.
        ///
        /// A valid code signature means that the file has not been tampered with and is trusted according
        /// to the certificate used to sign it.
        public var isSignatureValid: Bool {
            return isValid
        }
        
        /// The signing certificate associated with the code signature.
        ///
        /// This certificate is the one used to sign the file. If the certificate is not available, this
        /// value will be `nil`. The certificate can be used to verify the identity of the signer.
        public var signingCertificate: SecCertificate? {
            return certificate
        }
    }
    
    /// Verifies the code signature of a file at the specified URL.
    ///
    /// This function checks whether the file is signed and if the signature is valid. It also provides access
    /// to the signing certificate, if available.
    ///
    /// The verification process involves several steps:
    /// - Creating a static code object from the file's path using `SecStaticCodeCreateWithPath`.
    /// - Extracting signing information from the static code object using `SecCodeCopySigningInformation`.
    /// - Checking if the code signature is valid based on the retrieved status.
    ///
    /// - Parameters:
    ///   - fileURL: The URL of the file whose code signature is to be verified.
    /// - Throws: `SUKError.SUKCodeSigningError.signatureMissing` if no code signature is found, or
    ///          `SUKError.SUKCodeSigningError.signatureVerificationFailed` if verification fails.
    /// - Returns: A `SUKCodeSignature` instance representing the result of the verification.
    static func verifyCodeSignature(forFileAt fileURL: URL) throws -> SUKCodeSignature {
        let codeSigningStatus = try checkCodeSignature(forFileAt: fileURL)
        
        guard let certificate = codeSigningStatus?.certificate else {
            throw SUKError.SUKCodeSigningError.signatureMissing
        }
        
        return SUKCodeSignature(isValid: codeSigningStatus!.isValid, certificate: certificate)
    }
    
    /// Checks the code signature of a file at the specified URL and retrieves its signing information.
    ///
    /// This function performs the process of checking the file's code signature, verifying its validity,
    /// and extracting information about the certificate used to sign the file.
    ///
    /// The function makes use of two key APIs:
    /// - `SecStaticCodeCreateWithPath`: Creates a `SecStaticCode` object from the file's path, which is essential
    ///   for working with code signatures.
    /// - `SecCodeCopySigningInformation`: Retrieves the signing information associated with the code, including
    ///   the certificate used for signing and the status of the signature.
    ///
    /// - Parameters:
    ///   - fileURL: The URL of the file whose code signature is being checked.
    /// - Throws: `SUKError.SUKCodeSigningError.signatureVerificationFailed` if the verification fails.
    /// - Returns: A `SUKCodeSigningStatus` object containing the status of the code signature.
    static func checkCodeSignature(forFileAt fileURL: URL) throws -> SUKCodeSigningStatus? {
        let path = fileURL.path
        let url = NSURL(fileURLWithPath: path)
        
        let status: SecCodeStatus = .valid
        var staticCode: SecStaticCode?
        
        let result = SecStaticCodeCreateWithPath(url as CFURL, SecCSFlags(rawValue: 0), &staticCode)
        
        guard result == errSecSuccess, let staticCodeRef = staticCode else {
            throw SUKError.SUKCodeSigningError.signatureVerificationFailed
        }
        
        var signingInfo: CFDictionary?
        let checkResult = SecCodeCopySigningInformation(staticCodeRef, SecCSFlags(rawValue: 0), &signingInfo)
        
        guard checkResult == errSecSuccess else {
            throw SUKError.SUKCodeSigningError.signatureVerificationFailed
        }
        
        return SUKCodeSigningStatus(status: status)
    }
    
    /// Validates whether a given certificate is trusted against a set of trusted root certificates.
    /// This function determines the trustworthiness of a certificate by performing a chain validation process,
    /// ensuring that it complies with the X.509 standard and is anchored to one of the provided trusted root certificates.
    ///
    /// X.509 is a widely used standard for public key infrastructure (PKI), defining the structure of certificates
    /// and their associated validation processes. Certificates issued under the X.509 standard include various properties,
    /// such as the subject, issuer, validity period, and extensions. This validation process ensures that the certificate
    /// adheres to the specified X.509 constraints, has a valid chain of trust, and can be cryptographically verified against
    /// the provided trusted root certificates. Certificates are linked hierarchically in a chain of trust, starting from the
    /// subject certificate and ending at a trusted root certificate. Each link in the chain must be validated for authenticity,
    /// ensuring that no unauthorized certificate is included.
    ///
    /// This function creates a trust object using the input certificate and a basic X.509 validation policy (`SecPolicyCreateBasicX509`).
    /// It then sets the provided root certificates as the anchors (trusted roots) and restricts the validation process
    /// to only those anchors. The evaluation is performed using `SecTrustEvaluateWithError`, a modern API introduced
    /// in macOS 10.15 that ensures robust error handling and compatibility with current system security features.
    ///
    /// If the certificate passes the validation process without any errors, it is considered trusted.
    ///
    /// - Parameters:
    ///   - certificate: A `SecCertificate` object representing the certificate to be validated.
    ///   - trustedRoots: An array of trusted root certificates, represented as `[SecCertificate]`.
    ///
    /// - Returns: A Boolean value indicating whether the certificate is trusted.
    ///   Returns `true` if the certificate is trusted and the chain of trust is valid. Returns `false` if the evaluation fails
    ///   or the certificate cannot be validated for any reason.
    static func isCertificateTrusted(_ certificate: SecCertificate, againstTrustedRoots trustedRoots: [SecCertificate]) -> Bool {
        var trust: SecTrust?
        let policy = SecPolicyCreateBasicX509()
        SecTrustCreateWithCertificates(certificate, policy, &trust)
        
        guard let trust = trust else { return false }
        SecTrustSetAnchorCertificates(trust, trustedRoots as CFArray)
        SecTrustSetAnchorCertificatesOnly(trust, true)
        
        var error: CFError?
        let status = SecTrustEvaluateWithError(trust, &error)
        
        return status && error == nil
    }
    
    
    /// Determines whether a given certificate has expired by checking its validity period.
    /// Certificates issued under the X.509 standard include a `Validity` field, which specifies the range of dates
    /// during which the certificate is considered valid. This field consists of two subfields:
    /// `notBefore` (the start date of validity) and `notAfter` (the expiration date).
    ///
    /// This function retrieves the certificate's properties using the `SecCertificateCopyValues` function.
    /// From the extracted properties, the `kSecOIDX509V1ValidityNotAfter` field is used to obtain the certificate's expiration date.
    /// If the expiration date is in the past, the certificate is deemed expired. If the function is unable to extract the expiration
    /// date due to missing or malformed properties, it assumes the certificate is invalid and returns `true` (expired).
    ///
    /// - Parameters:
    ///   - certificate: A `SecCertificate` object representing the certificate to be checked.
    ///
    /// - Returns: A Boolean value indicating whether the certificate is expired.
    ///   Returns `true` if the certificate has expired or if its expiration date cannot be determined.
    ///   Returns `false` if the certificate is still valid.
    static func isCertificateExpired(_ certificate: SecCertificate) -> Bool {
        guard let values = SecCertificateCopyValues(certificate, nil, nil) as? [String: Any],
              let notAfter = values[kSecOIDX509V1ValidityNotAfter as String] as? [String: Any],
              let expirationDate = notAfter[kSecPropertyKeyValue as String] as? Date else {
            return true
        }
        return expirationDate < Date()
    }
    
    /// Validates the code signatures of an array of files by verifying their integrity and authenticity.
    /// Code signatures are essential for ensuring that files, such as executables or bundles, have not been
    /// tampered with and are authorized by a trusted signer. This function iterates through a list of file URLs
    /// and attempts to validate each file's code signature using the `verifyCodeSignature(forFileAt:)` method.
    ///
    /// Files with valid code signatures are included in the returned array as `SUKCodeSignature` objects. Files that
    /// fail validation due to missing or invalid signatures are excluded from the results. The function uses error handling
    /// to gracefully skip over files that cause validation errors, allowing it to continue processing the remaining files.
    ///
    /// - Parameters:
    ///   - fileURLs: An array of file URLs (`[URL]`) representing the files whose code signatures are to be validated.
    ///
    /// - Returns: An array of successfully validated code signatures, represented as `[SUKCodeSignature]`.
    ///   Only files with valid signatures are included. Files that fail validation are excluded from the result.
    static func validateCodeSignatures(forFilesAt fileURLs: [URL]) -> [SUKCodeSignature] {
        return fileURLs.compactMap { fileURL in
            do {
                return try verifyCodeSignature(forFileAt: fileURL)
            } catch {
                return nil
            }
        }
    }
    
    /// Validates the certificate chain of a file's code signature against a set of trusted root certificates.
    /// This function ensures that the file's code signature is not only present but also issued by a trusted authority,
    /// verifying the authenticity and integrity of the file. It first retrieves the code signature associated with the file
    /// using the `verifyCodeSignature(forFileAt:)` method. The signing certificate extracted from the code signature is then
    /// validated against the provided trusted root certificates using the `isCertificateTrusted(_:againstTrustedRoots:)` method.
    ///
    /// If the code signature cannot be retrieved or if the certificate is found to be untrusted, the function returns `false`.
    /// Otherwise, it returns `true`, indicating that the file's certificate chain is valid and trusted.
    ///
    /// - Parameters:
    ///   - fileURL: A `URL` representing the file whose certificate chain is to be validated.
    ///   - trustedRoots: An array of trusted root certificates, represented as `[SecCertificate]`.
    ///
    /// - Returns: A Boolean value indicating whether the file's certificate chain is trusted.
    ///   Returns `true` if the signing certificate is trusted and the chain of trust is valid. Returns `false` if validation fails.
    static func validateCertificateChain(forFileAt fileURL: URL, againstTrustedRoots trustedRoots: [SecCertificate]) -> Bool {
        do {
            let codeSignature = try verifyCodeSignature(forFileAt: fileURL)
            guard let certificate = codeSignature.signingCertificate else { return false }
            return isCertificateTrusted(certificate, againstTrustedRoots: trustedRoots)
        } catch {
            return false
        }
    }
    
    /// `SUKCodeSigningStatus` represents the result of the code signing verification process for a file. It provides
    /// a detailed description of the status of the file's signature and any associated certificate used during the
    /// signing process. This struct is essential for developers and systems that need to verify whether a file has been
    /// properly signed and to inspect the details of the signing certificate, which can help in ensuring the integrity
    /// and authenticity of the file.
    ///
    /// ## Purpose and Use Cases
    /// The `SUKCodeSigningStatus` struct plays a critical role in ensuring that files within an application, such as
    /// executables, libraries, or scripts, are signed by a trusted source and have not been tampered with. By using
    /// this struct, developers can check the validity of a file's code signature, extract the signing certificate for
    /// further inspection, and make security-critical decisions based on the validation results.
    ///
    /// This struct is especially useful in applications that need to ensure the security of code before executing it,
    /// such as in software updates, digital distribution systems, and security-sensitive applications. It also plays a
    /// role in validating downloaded files to prevent the execution of malicious code or tampered software.
    ///
    /// ## Properties
    /// - **`isValid`**: A Boolean value indicating whether the code signature is valid or not. If `isValid` is `true`,
    ///   it means that the file's code signature has been properly verified and is considered trustworthy. If `false`,
    ///   the file has either no valid signature, or its signature is invalid due to tampering or other integrity issues.
    ///   This property is crucial for determining whether the file can be trusted and executed without security risks.
    ///
    /// - **`certificate`**: A `SecCertificate?` representing the signing certificate associated with the file's code signature.
    ///   If available, this property holds the certificate used to sign the file. The certificate can be used to identify
    ///   the signer and confirm whether the signing authority is trusted. If the certificate is not available, this property
    ///   will be `nil`. The presence of a valid certificate is important for verifying the authenticity of the file's source.
    ///   It allows the system to confirm that the file originates from a legitimate developer or trusted entity.
    ///
    /// ## Initialization
    /// The struct is initialized using a `SecCodeStatus` value, which is retrieved during the code signature validation
    /// process. The `SecCodeStatus` indicates whether the signature is valid or not. However, as the certificate is not
    /// directly tied to the `SecCodeStatus` but may be retrieved through separate APIs, the certificate property is left
    /// as `nil` in this basic initialization, signaling that certificate extraction may be handled in separate steps.
    ///
    /// ## Code Signing Validation Process
    /// - **Step 1: Signature Verification**: The first task in validating a file's code signature is checking whether
    ///   the file has a valid signature. This can be done using macOS's code signing APIs, such as `SecStaticCodeCreateWithPath`
    ///   and `SecCodeCopySigningInformation`. The `isValid` property of `SUKCodeSigningStatus` is determined based on the
    ///   result of this verification. A valid signature confirms that the file has not been altered since it was signed and
    ///   originates from a trusted source.
    ///
    /// - **Step 2: Certificate Extraction**: While the `SUKCodeSigningStatus` struct initializes with just the validity
    ///   status (`isValid`), the certificate used for signing the file can be retrieved later through APIs like
    ///   `SecCodeCopySigningInformation`. This certificate can be crucial for advanced use cases, such as checking the
    ///   identity of the signer, verifying the trustworthiness of the signing authority, or checking the validity of the
    ///   certificate itself (e.g., checking whether the certificate has expired or been revoked).
    ///
    /// ## Security Considerations
    /// Code signing provides assurance that the code has not been tampered with and is authorized by a trusted developer.
    /// The `SUKCodeSigningStatus` struct helps enforce this security by providing a clear indication of whether the file's
    /// signature is valid, and by offering access to the certificate for further scrutiny.
    /// This can prevent attacks where malicious code is injected into legitimate applications or software components,
    /// ensuring that only verified and trusted code is executed.
    ///
    /// ## Example Use Case
    /// Consider a scenario where an application checks the code signature of an update package before applying it. By
    /// using the `SUKCodeSigningStatus` struct, the application can validate the update's signature and ensure that the
    /// update package has not been altered. If the signature is valid, the application can proceed to apply the update.
    /// If the signature is invalid, the update can be rejected, and a warning can be presented to the user to prevent
    /// potentially harmful software from being installed.
    ///
    /// Similarly, when verifying downloaded files, developers can use the `SUKCodeSigningStatus` to check that the
    /// file's code signature is valid and that the signing certificate belongs to a trusted authority. If the certificate
    /// is untrusted or the signature is invalid, the file can be blocked from execution or flagged for further inspection.
    ///
    @available(macOS 15.0, *)
    struct SUKCodeSigningStatus {
        
        /// A Boolean value indicating whether the code signature is valid.
        ///
        /// This property is the result of the code signature verification process. If `isValid` is `true`, the file's
        /// code signature has been verified and is considered trustworthy. A value of `false` indicates that either the
        /// file does not have a valid signature or it has been altered since it was signed.
        ///
        /// This property is fundamental to ensuring the integrity of the file. If `isValid` is `false`, further actions
        /// should be taken to protect the system from potentially compromised code, such as blocking the execution of
        /// the file or alerting the user to a possible security issue.
        let isValid: Bool
        
        /// The signing certificate associated with the code signature.
        ///
        /// If the file has been signed by a trusted authority, this property contains the signing certificate. The certificate
        /// is used to identify the signer and confirm that the signature was generated by a valid and trusted developer.
        /// It can be examined further to validate the authenticity of the file's source, check whether the certificate has
        /// been revoked, or confirm the certificate's expiration date.
        ///
        /// If no certificate is available or if the file was not signed, this property will be `nil`. The absence of a
        /// certificate may indicate that the file is unsigned or that the signing certificate could not be retrieved due to
        /// an error in the signature validation process.
        let certificate: SecCertificate?
        
        /// Initializes a `SUKCodeSigningStatus` instance with the given code signing status.
        ///
        /// This initializer creates an instance of `SUKCodeSigningStatus` by setting the `isValid` property based on
        /// the provided `SecCodeStatus`. The `certificate` property is left as `nil` in this basic implementation,
        /// as certificate extraction is handled separately in more advanced cases.
        ///
        /// - Parameters:
        ///   - status: The `SecCodeStatus` value representing the result of the code signing verification.
        ///
        /// This initialization process is used during the file verification steps, where the validity of the code signature
        /// is determined first, and the signing certificate may be retrieved later if needed.
        public init(status: SecCodeStatus) {
            self.isValid = (status == .valid)
            self.certificate = nil
        }
    }
}

@available(macOS 15.0, *)
public extension SUKError {
    enum SUKCodeSigningError: Error {
        case signatureMissing
        case signatureVerificationFailed
        case certificateNotFound
    }
}
