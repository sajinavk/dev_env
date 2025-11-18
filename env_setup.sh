#!/bin/bash

### -----------------------------------------------------------
###  REQUIRE ROOT
### -----------------------------------------------------------
if [ "$EUID" -ne 0 ]; then
  echo "Please run as sudo:"
  echo "  sudo $0"
  exit 1
fi

### -----------------------------------------------------------
###  INSTALL DEPENDENCIES
### -----------------------------------------------------------
echo "Installing dependencies: zsh, curl, git ..."
apt update -y
apt install -y zsh curl git

### -----------------------------------------------------------
###  INSTALL OH-MY-ZSH SILENTLY
### -----------------------------------------------------------
echo "Installing Oh My Zsh..."

# Install oh-my-zsh silently for the invoking user
sudo -u "$SUDO_USER" sh -c \
  'curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash -s -- --unattended'

### -----------------------------------------------------------
###  SET DEFAULT SHELL TO ZSH
### -----------------------------------------------------------
echo "Setting zsh as default shell for $SUDO_USER ..."
chsh -s "$(which zsh)" "$SUDO_USER"

### -----------------------------------------------------------
###  APPLY CUSTOM NANO SETTINGS
### -----------------------------------------------------------
NANORC="/etc/nanorc"
echo "Applying nano customizations to $NANORC ..."

apply_setting() {
    local setting="$1"
    local escaped
    escaped=$(printf '%s\n' "$setting" | sed 's/[.[\*^$(){}?+|/]/\\&/g')

    if grep -q "^# *$escaped" "$NANORC"; then
        sed -i "s/^# *$escaped/$setting/" "$NANORC"
        echo "Uncommented: $setting"
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

### -----------------------------------------------------------
###  DONE
### -----------------------------------------------------------
echo
echo "-------------------------------------------------------"
echo " Done! Logout/login or run:  zsh "
echo "-------------------------------------------------------"
# Start zsh immediately for the invoking user
sudo -u "$SUDO_USER" zsh
