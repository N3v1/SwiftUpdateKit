#!/usr/bin/perl
use strict;
use warnings;

my $swift_lint = "/opt/homebrew/bin/swiftlint";
my $swift_format = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-format";

# Define color codes
my $RED = "\033[0;31m";
my $GREEN = "\033[0;32m";
my $YELLOW = "\033[0;33m";
my $BLUE = "\033[0;34m";
my $BOLD = "\033[1m";
my $RESET = "\033[0m";
my $ORANGE = "\033[38;5;214m";
my $GRAY = "\033[0;37m";

sub greeting {
    print "${BOLD}${ORANGE}";
    print <<'EOF';
 ___         _ _    _    _       ___                   _   _
/ __| __ _ _(_) |__| |__| |___  | __|__ _ _ _ __  __ _| |_| |_ ___ _ _
\__ \/ _| '_| | '_ \ '_ \ / -_) | _/ _ \ '_| '  \/ _` |  _|  _/ -_) '_|
|___/\__|_| |_|_.__/_.__/_\___| |_|\___/_| |_|_|_\__,_|\__|\__\___|_|

ScribbleLabApp LLC. › ScribbleFoundation
Copyright (c) 2024 ScribbleFoundation - All rights reserved.
EOF
    print "${RESET}\n";
}

sub check_command {
    my $command = shift;
    my $path = shift;
    if (-e $path) {
        print "${BOLD}${GREEN}==>$RESET $command found at $path.$RESET\n";
        return 1;
    } else {
        print "${YELLOW}${BOLD}[WARNING]:$RESET $command is not installed or cannot be found at $path.$RESET\n";
        return 0;
    }
}

sub run_swiftlint {
    my $config_path = "./.swiftlint.yml";
    
    if (-e $config_path) {
        print "${BOLD}${GREEN}==>$RESET Config file found at $config_path.$RESET\n";
    
        my $lint_output = `$swift_lint --config $config_path`;
        if ($? == 0) {
            print "\n${YELLOW}${BOLD}============================= Linting results =============================$RESET\n${GRAY}$lint_output$RESET$RESET";
            print "${BOLD}${GREEN}==>$RESET SwiftLint completed successfully.$RESET\n";
        } else {
            print "${RED}${BOLD}==> SwiftLint encountered issues:$RESET\n${RED}$lint_output$RESET$RESET\n";
            return 0;
        }
    } else {
        print "${RED}${BOLD}[ERROR]: SwiftLint config file not found at $config_path.$RESET\n";
        return 0;
    }
}

sub run_swiftformat {
    my $format_output = `$swift_format --recursive .`;
    if ($? == 0) {
        print "${BOLD}${GREEN}==>$RESET SwiftFormat completed successfully.$RESET\n";
    } else {
        print "${RED}${BOLD}SwiftFormat encountered issues:\n$format_output$RESET\n";
        return 0;
    }
}

sub main {
    greeting();
    
    print "${BLUE}${BOLD}==>$RESET Searching for swiftlint and swift-format...$RESET\n";
    if (check_command('SwiftLint', $swift_lint) && check_command('SwiftFormat', $swift_format)) {
        print "${BLUE}${BOLD}==>$RESET Linting codebase...$RESET\n";
        run_swiftlint();
        print "\n";
        
        print "${BLUE}${BOLD}==>$RESET Formatting codebase...$RESET\n";
        run_swiftformat();
    } else {
        print "${RED}${BOLD} [ERROR]: Cannot proceed - SwiftLint and/or SwiftFormat are not installed.$RESET\n";
        return 0;
    }
}

main();
