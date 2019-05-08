#!/bin/sh -e

xcconfig=$(mktemp /tmp/static.xcconfig.XXXXXX)
trap 'rm -f "$xcconfig"' INT TERM HUP EXIT

echo "LD = $PWD/Carthage/ld.py" >> $xcconfig
echo "DEBUG_INFORMATION_FORMAT = dwarf" >> $xcconfig
#echo "SWIFT_VERSION = 3.2" >> $xcconfig
#echo "TOOLCHAINS = com.apple.dt.toolchain.Swift_3_2" >> $xcconfig

export XCODE_XCCONFIG_FILE="$xcconfig"

carthage build "$@"