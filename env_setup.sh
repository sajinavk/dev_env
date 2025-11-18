#!/bin/bash

# This script applies custom nano settings to /etc/nanorc

NANORC="/etc/nanorc"

# Require sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run as sudo:"
  echo "  sudo $0"
  exit 1
fi

echo "Applying nano customizations to $NANORC ..."

# Helper: uncomment a line if present, otherwise add it
apply_setting() {
    local setting="$1"
    local escaped=$(printf '%s\n' "$setting" | sed 's/[.[\*^$(){}?+|/]/\\&/g')

    # If commented, uncomment
    if grep -q "^# *$escaped" "$NANORC"; then
        sed -i "s/^# *$escaped/$setting/" "$NANORC"
        echo "Uncommented: $setting"
    # If missing entirely, append
    elif ! grep -q "^$escaped" "$NANORC"; then
        echo "$setting" >> "$NANORC"
        echo "Added: $setting"
    else
        echo "Already present: $setting"
    fi
}

apply_setting "set autoindent"
apply_setting "set constantshow"
apply_setting "set indicator"
apply_setting "set linenumbers"
apply_setting "set matchbrackets \"(<[{)>]}\""
apply_setting "set mouse"
apply_setting "set positionlog"

echo "Done! Test with: nano"
