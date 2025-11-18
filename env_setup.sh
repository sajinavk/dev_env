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
###  USER DETECTION
### -----------------------------------------------------------
# Detect the non-root user running sudo
if [ -z "$SUDO_USER" ]; then
  echo "Could not detect non-root user. Exiting."
  exit 1
fi

USER_NAME="$SUDO_USER"
HOME_DIR=$(eval echo "~$USER_NAME")

### -----------------------------------------------------------
###  INSTALL DEPENDENCIES
### -----------------------------------------------------------
echo "Installing dependencies: zsh, curl, git ..."
apt update -y
apt install -y zsh curl git

### -----------------------------------------------------------
###  INSTALL OH-MY-ZSH SILENTLY
### -----------------------------------------------------------
echo "Installing Oh My Zsh for $USER_NAME..."
sudo -u "$USER_NAME" sh -c \
  "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Make zsh the default shell
chsh -s "$(which zsh)" "$USER_NAME"
echo "Default shell set to zsh for $USER_NAME"

### -----------------------------------------------------------
###  APPLY CUSTOM NANO SETTINGS
### -----------------------------------------------------------
NANORC="/etc/nanorc"
echo "Applying nano customizations to $NANORC ..."

apply_setting() {
    local setting="$1"
    local escaped=$(printf '%s\n' "$setting" | sed 's/[.[\*^$(){}?+|/]/\\&/g')

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
###  FINISH
### -----------------------------------------------------------
echo
echo "-------------------------------------------------------"
echo " Setup complete!"
echo " - Oh My Zsh installed for $USER_NAME"
echo " - Default shell changed to zsh"
echo " - Nano customized"
echo "Please log out and back in, or open a new terminal to start using zsh."
echo "-------------------------------------------------------"

# Optional: uncomment to automatically reboot
# echo "Rebooting in 5 seconds..."
# sleep 5
# reboot
