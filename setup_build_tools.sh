#!/bin/sh

#
# Install all the required dependencies for building and deploying Pocket for iOS
# Assumes you already have git otherwise you wouldn't have this setup script
#
# run ./setup_build_tools.sh from the command line to run
#

#
# Check if XCode Command Line Tools are installed
#
which -s xcode-select
if [[ $? != 0 ]] ; then
	echo "Installing XCode Command Line Tools"
	# Install XCode Command Line Tools
	xcode-select --install
else
	echo "XCode Command Line Tools already installed"
fi

#
# Check if Homebrew is installed
#
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
	echo "Installing Homebrew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
	echo "Homebrew already installed"
fi

#
# Check if Swiftlint is installed
#
which -s swiftlint
if [[ $? != 0 ]] ; then
    # Install Swiftlint
	echo "Installing Swiftlint"
    brew install swiftlint
else
	echo "Swiftlint already installed"
fi

