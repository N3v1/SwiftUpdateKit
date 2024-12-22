#!/usr/bin/perl
use strict;
use warnings;

# Define the paths to the SwiftLint and SwiftFormat commands
my $swift_lint = "swiftlint";
my $swift_format = "swiftformat";

# Check if SwiftLint is installed
sub check_command {
    my $command = shift;
    my $output = `which $command`;
    if ($? == 0 && $output ne '') {
        print "$command is installed.\n";
        return 1;
    } else {
        print "Warning: $command is not installed.\n";
        return 0;
    }
}

# Run SwiftLint
sub run_swiftlint {
    print "Running SwiftLint...\n";
    my $lint_output = `$swift_lint`;
    if ($? == 0) {
        print "SwiftLint completed successfully.\n";
    } else {
        print "SwiftLint encountered issues:\n$lint_output\n";
    }
}

# Run SwiftFormat
sub run_swiftformat {
    print "Running SwiftFormat...\n";
    my $format_output = `$swift_format .`;
    if ($? == 0) {
        print "SwiftFormat completed successfully.\n";
    } else {
        print "SwiftFormat encountered issues:\n$format_output\n";
    }
}

# Main logic
sub main {
    # Check if both SwiftLint and SwiftFormat are installed
    if (check_command('swiftlint') && check_command('swiftformat')) {
        run_swiftlint();
        run_swiftformat();
    } else {
        print "Cannot proceed: SwiftLint and/or SwiftFormat are not installed.\n";
    }
}

# Execute the main function
main();
