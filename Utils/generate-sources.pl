#!/usr/bin/perl

#  Copyright (c) 2015 - 2024 Apple Inc. - All rights reserved.
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
use File::Basename;
use File::Path qw(make_path remove_tree);
use File::Compare;
use File::Temp qw(tempdir);

my $srcroot = dirname($0);
$srcroot = "$srcroot/..";
chdir($srcroot) or die "Cannot change to directory $srcroot: $!";

my $gyb = "./Utils/gyb";

my $lineDirective = '';

my $tmpdir = tempdir(CLEANUP => 1);

my $log_file = "$tmpdir/generated-files.txt";
open my $log_fh, '>>', $log_file or die "Cannot open log file: $!";

my @files = glob("./Sources/*.swift.gyb");
push @files, glob("./Tests/*.swift.gyb");

foreach my $input (@files) {
    my $basename = basename($input);
    my $targetdir = dirname($input) . "/autogenerated";
    my $output = "$targetdir/" . substr($basename, 0, -4);
    my $tmpfile = "$tmpdir/" . substr($basename, 0, -4);

    make_path($targetdir) unless -d $targetdir;

    my $gyb_command = "$gyb --line-directive $lineDirective -o $tmpfile $input";
    system($gyb_command) == 0 or die "GYB command failed: $!";

    if (-e $output && compare($tmpfile, $output) == 0) {
        print "Unchanged Preprocessors - Skipping...";
        next;
    } else {
        print "Updated $output\n";
        system("cp $tmpfile $output") == 0 or die "Failed to copy $tmpfile to $output: $!";
    }
    
    print $log_fh "$output\n";
}

close $log_fh;

open my $log_fh_read, '<', $log_file or die "Cannot open generated files log for reading: $!";
my %generated_files;
while (<$log_fh_read>) {
    chomp;
    $generated_files{$_} = 1;
}
close $log_fh_read;

my @all_generated = glob('*/autogenerated/*.swift');
foreach my $file (@all_generated) {
    unless (exists $generated_files{$file}) {
        print "Removing $file\n";
        unlink $file or warn "Could not remove $file: $!\n";
    }
}
