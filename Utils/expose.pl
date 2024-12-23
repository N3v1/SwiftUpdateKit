#!/usr/bin/perl

#  Copyright (c) 2024 ScribbleLabApp LLC.
#  Copyright (c) 2024 Nevio Hirani - All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#
#  1. Redistributions of source code must retain the above copyright notice, this
#     list of conditions and the following disclaimer.
#
#  2. Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#
#  3. Neither the name of the copyright holder nor the names of its
#     contributors may be used to endorse or promote products derived from
#     this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
#  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
#  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

use strict;
use warnings;
use File::Find;
use File::Slurp;

my @source_dirs = (
                   './SUKCore',
                   './SUKModels',
                   './SUKNetworking',
                   './SUKSecurity',
                   './SUKUtils',
                   './SwiftUpdateKitUI'
                   );

my $output_file = './SwiftUpdateKit/SwiftUpdateKit.swift';

my $license_header = <<"HEADER";
//
//  SwiftUpdateKit.swift
//  SwiftUpdateKit Umbrella Framework
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
//  IMPLIED WARRANTIES, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

HEADER

my $autogenerated_warning = << "AUTOGEN";
//
// #############################################################################
// #                                                                           #
// #            DO NOT EDIT THIS FILE; IT IS AUTOGENERATED.                    #
// #                                                                           #
// #############################################################################
//
// WARNING: This file is auto-generated by the code generation tool.
// Modifications to this file may be overwritten and lost if the code is regenerated.
// If you need to make changes, update the source schema or generation process instead.
// DO NOT EDIT THIS FILE MANUALLY.
//
// Auto-generated file: SwiftUpdateKit.swift
// Generated by `expose.pl`

AUTOGEN

my $imports = << "IMPS";
import SUKCore
import SUKUtils
import SUKModels
import SUKParsing
import SUKSecurity
import SUKNetworking
import SwiftUpdateKitUI

IMPS

my $existing_content = '';
if (-e $output_file) {
    $existing_content = read_file($output_file);
}

my $generated_symbols_marker = "// Generated symbols start";
if ($existing_content =~ /$generated_symbols_marker/) {
    print "Symbols are already generated. Skipping regeneration.\n";
    exit;
}

write_file($output_file, $license_header . "\n" . $autogenerated_warning . "\n" . $imports . "\n");

sub append_to_exposed_methods {
    my ($content, $framework, $filename) = @_;
    
    my $symbol = $content;
    my $doc_comment = "";
    
    if ($content =~ /\/\*\*.*?(\s*\/\/\/.*)/gs) {
        $doc_comment = $1;
        $doc_comment =~ s/\n\s*\/\/\s*/\n/g;
    }
    
    my $available_annotation = "";
    if ($content =~ /\s*\@available\(([^)]+)\)/g) {  # Escape @
        $available_annotation = "\@available($1)\n"; # Escape @
    } else {
        $available_annotation = "\@available(macOS 15.0, *)\n"; # Escape @
    }
    
    my $additional_attributes = "";
    while ($content =~ /\@(\w+(\([^\)]*\))?)/g) {  # Escape @
        my $attribute = $1;
        
        if ($attribute =~ /^(available|backDeployed|usableFromInline|objc|discardableResult|dynamicCallable|dynamicMemberLookup|freestanding|frozen|inlinable|main|nonobjc|NSCopying|NSManaged|objc\(\)|objcMembers|preconcurrency|propertyWrapper|WrapperWithProjection|resultBuilder|ArrayBuilder|DrawingBuilder|DrawingPartialBlockBuilder|requires_stored_property_inits|testable|unchecked|warn_unqualified_access|autoclosure|convention|escaping|Sendable|unknown|abi\(|binaryInterface|_silgen_name|_specialize)/) {
            $additional_attributes .= "$attribute ";
        }
    }
    
    $additional_attributes =~ s/\s+$//;
    
    my $final_content = "/* Exposed from $framework › $filename */\n";
    $final_content .= "$doc_comment\n" if $doc_comment;
    $final_content .= "$available_annotation";
    $final_content .= "$additional_attributes\n" if $additional_attributes;
    $final_content .= "$symbol\n\n";
    
    append_file($output_file, $final_content);
}

append_file($output_file, "// Generated symbols start\n");

foreach my $dir (@source_dirs) {
    find(sub {
        return unless /\.swift$/;
        
        my $file = $File::Find::name;
        my $content = read_file($file);
        
        my ($framework) = $file =~ m{(.+/)([^/]+)$};
        $framework = $2 || "Unknown";
        
        my ($filename) = $file =~ m{([^/]+)\.swift$};
        
        while ($content =~ /(\@SUKExport.*?)(public|internal|fileprivate|private)?\s*(func|var|let|class|enum|protocol|actor|final\s+class|subscript|static|struct)\s+\w+[\w\(\),<>\[\]]*\s*(\{[^}]*\})?/gs) {
            my $symbol = $1;
            my $visibility = $2 // '';
            my $type = $3;
            my $body = $4 // '';
            
            append_to_exposed_methods($symbol . $visibility . $type . $body, $framework, $filename);
        }
}, $dir);
}

append_file($output_file, "// Generated symbols end\n");

print "Exposed symbols written to $output_file\n";
