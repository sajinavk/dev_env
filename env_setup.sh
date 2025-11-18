#!/bin/bash

### -----------------------------------------------------------

### REQUIRE ROOT

### -----------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
echo "Please run as sudo:"
echo "  sudo $0"
exit 1
fi

USER_NAME=${SUDO_USER:-$USER}

### -----------------------------------------------------------

### INSTALL DEPENDENCIES

### -----------------------------------------------------------

echo "Installing dependencies: zsh, curl, git ..."
apt update -y
apt install -y zsh curl git

### -----------------------------------------------------------

### INSTALL OH-MY-ZSH SILENTLY

### -----------------------------------------------------------

echo "Installing Oh My Zsh for $USER_NAME..."

sudo -u "$USER_NAME" sh -c 
"$(curl -fsSL [https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh](https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh))" <<EOF
y
y
EOF

### -----------------------------------------------------------

### SET ZSH AS DEFAULT SHELL

### -----------------------------------------------------------

echo "Setting Zsh as default shell for $USER_NAME..."
chsh -s "$(which zsh)" "$USER_NAME"

### -----------------------------------------------------------

### APPLY CUSTOM NANO SETTINGS

### -----------------------------------------------------------

NANORC="/etc/nanorc"
echo "Applying nano customizations to $NANORC ..."

apply_setting() {
local setting="$1"
local escaped=$(printf '%s\n' "$setting" | sed 's/[.[*^$(){}?+|/]/\&/g')

```
if grep -q "^# *$escaped" "$NANORC"; then
    sed -i "s/^# *$escaped/$setting/" "$NANORC"
    echo "Uncommented: $setting"
elif ! grep -q "^$escaped" "$NANORC"; then
    echo "$setting" >> "$NANORC"
    echo "Added: $setting"
else
    echo "Already present: $setting"
fi
```

}

apply_setting "set autoindent"
apply_setting "set constantshow"
apply_setting "set indicator"
apply_setting "set linenumbers"
apply_setting "set matchbrackets "(<[{)>]}""
apply_setting "set mouse"
apply_setting "set positionlog"

echo
echo "-------------------------------------------------------"
echo " Done! Zsh is now the default shell for $USER_NAME."
echo "A reboot is recommended to apply changes completely."
echo "-------------------------------------------------------"

### -----------------------------------------------------------

### OPTIONAL: REBOOT AUTOMATICALLY

### -----------------------------------------------------------

read -p "Reboot now? [y/N]: " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
echo "Rebooting..."
reboot
fi
