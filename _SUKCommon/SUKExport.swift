//
//  SUKExport.swift
//  _SUKCommon
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

/// `@SUKExport` Attribute Class Documentation
///
/// The `@SUKExport` attribute is a key component of the code generation system used in the `SwiftUpdateKit` framework.
/// This attribute is designed to automatically expose certain symbols, such as functions, variables, classes, and enums,
/// to a central framework that handles the management of globally accessible resources. The `@SUKExport` attribute simplifies
/// the process of making symbols available across different modules of the project without manually adding declarations
/// or modifying individual files. By using `@SUKExport`, developers can ensure that the right resources are always
/// accessible and consistently managed across the entire project.
///
/// ### Purpose
/// The primary purpose of the `@SUKExport` attribute is to create a seamless integration between various modules and
/// facilitate global access to the symbols marked with it. The attribute ensures that any symbol it decorates is automatically
/// included in the generated `SwiftUpdateKit.swift` file, which centralizes all exposed resources. This centralized file acts
/// as a shared resource hub, where common functions, variables, classes, and enums can be easily referenced and used
/// throughout the entire project without needing explicit imports or declarations in every file.
///
/// ### Code Generation Process
/// When the `@SUKExport` attribute is applied to a symbol in the codebase, the following sequence of events occurs:
///
/// 1. **Code Parsing**: The code generation tool (`expose.pl`) scans the source code files across predefined
///                  directories (such as `./SUKCore`, `./SUKModels`, `./SUKNetworking`, etc.) and
///                  identifies symbols annotated with the `@SUKExport` attribute.
///
/// 2. **Symbol Extraction**: Once the `@SUKExport` attribute is detected, the tool extracts the relevant symbol,
///                      including its visibility modifier (such as `public`, `internal`, `fileprivate`, or `private`),
///                      type (such as `func`, `var`, `let`, `class`, `enum`), availability information,
///                      DocC comments, and any other attributes that may be present.
///
/// 3. **Metadata Handling**: Additional information, such as documentation comments or platform-specific availability annotations,
///                      are processed to ensure that any exposed symbols carry sufficient context and metadata for proper use.
///
/// 4. **File Generation**: The tool then generates a `SwiftUpdateKit.swift` file. This file contains all the exposed symbols,
///                    organized and ready to be imported into other modules or used globally. The generated file will also include
///                    the relevant doc comments and metadata, making it easier for developers to understand and utilize the
///                    exported symbols.
///
/// 5. **Continuous Synchronization**: The `SwiftUpdateKit.swift` file is automatically updated whenever new symbols are
///                             added or existing ones are modified. This ensures that all resources exposed via `@SUKExport`
///                             remain up-to-date across the entire project.
///
/// ### Example Usage
/// The `@SUKExport` attribute is applied directly above a symbol (function, variable, class, etc.) to expose it to the central
/// `SwiftUpdateKit.swift` file. Here’s an example of how to use the `@SUKExport` attribute with a function:
///
/// ```swift
/// @SUKExport
/// public func fetchLatestUpdate() {
///     // Implementation of the function to fetch the latest update
/// }
/// ```
/// In this example, the `fetchLatestUpdate` function will be automatically added to the generated `SwiftUpdateKit.swift`
/// file, making it available globally to any other module that imports `SwiftUpdateKit`.
///
/// Additionally, classes, enums, and other types can also be marked with `@SUKExport` for exposure. For example:
///
/// ```swift
/// @SUKExport
/// public class UpdateManager {
///     // Class implementation
/// }
/// ```
///
/// This class will also be exposed globally and can be referenced in other parts of the project.
///
/// ### Supported Symbols
/// The `@SUKExport` attribute can be used to expose the following types of symbols:
/// - **Functions**: Both instance and class functions (e.g., `func`, `static func`)
/// - **Variables**: Properties and constants (e.g., `var`, `let`)
/// - **Classes**: Regular classes and subclassed types (e.g., `class`, `final class`)
/// - **Enums**: Enumeration types (e.g., `enum`)
/// - **Structs**: Structure types (e.g., `struct`)
///
/// ### Integration with Other Annotations
/// The `@SUKExport` attribute works in conjunction with several other Swift annotations, such as visibility modifiers,
/// documentation comments, and availability annotations, to create a robust system for exporting and managing symbols.
///
/// - **Visibility Modifiers**: The symbols marked with `@SUKExport` will respect Swift’s visibility modifiers. For example,
///                      if a symbol is marked `public`, it will be exposed globally, while symbols marked as `internal`
///                      will only be accessible within the project.
///
/// - **Doc Comments**: If the symbol has associated doc comments (e.g., `/** ... */` or `/// ...`), those comments
///                    will be carried over into the generated file, providing valuable context for developers using the exposed symbol.
///
/// - **Availability Annotations**: Availability annotations (e.g., `@available(macOS 10.15, *)`) are preserved when generating
///                          the exposed symbols, ensuring that platform compatibility is properly communicated.
///
/// ### Generated File and Auto-Updates
/// All symbols exposed via `@SUKExport` are automatically included in the `SwiftUpdateKit.swift` file, which is generated
/// and updated as part of the code generation process. This file contains all of the project’s globally accessible resources
/// in a centralized location, making it easier for developers to reference and manage them.
///
/// - **Do Not Edit Manually**: The `SwiftUpdateKit.swift` file is auto-generated and should not be edited manually.
///                        Any changes made directly to this file will be overwritten the next time the code generation tool is run.
/// - **Automatic Synchronization**: The generation tool runs on a regular basis, ensuring that any new symbols marked
///                             with `@SUKExport` are automatically added to the file, and any modifications are
///                             reflected in the next update.
///
/// ### Benefits
/// The use of the `@SUKExport` attribute simplifies the process of exposing symbols across modules, streamlining the
/// management of shared resources. It helps to avoid redundancy, ensures consistency, and reduces the likelihood of errors
/// due to manual exports. Additionally, it supports a centralized management system that keeps your codebase clean and
/// well-organized.
///
/// ### Best Practices
/// - **Use for Shared Resources**: The `@SUKExport` attribute should be used for symbols that need to be globally
/// accessible. For example, helper functions, common constants, and shared classes that are used in multiple modules
/// should be exported.
///
/// - **Limit Use for Internal Code**: Avoid marking symbols with `@SUKExport` unless they are intended to be publicly
/// accessible across the project. Internal methods or data structures should remain private or internal to their respective
/// modules.
///
/// ### Notes
/// - **Automatic Code Generation**: Ensure the code generation tool (`expose.pl`) is run regularly to keep the
/// `SwiftUpdateKit.swift` file up-to-date with the latest exposed symbols.
/// - **Cross-Module Exposure**: The `@SUKExport` attribute makes it easy to expose symbols across different modules,
/// helping developers to build clean and efficient modular codebases.
@available(macOS 15.0, *)
@objc public class SUKExport: NSObject {}
