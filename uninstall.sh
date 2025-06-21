#!/bin/bash

if [ -w "$PREFIX/bin/localhost" ]; then
    rm -f "$PREFIX/bin/localhost"
elif [ -w "$HOME/bin/localhost" ]; then
    rm -f "$HOME/bin/localhost"
fi

if [ -f "/tmp/localhost_port" ]; then
    rm -f "/tmp/localhost_port"
fi

for config_file in ~/.bashrc ~/.zshrc; do
    if [ -f "$config_file" ]; then
        sed -i '/alias localhost=/d' "$config_file"
        sed -i '/alias stoplocal=/d' "$config_file"
    fi
done

echo "Uninstallation complete. You may need to restart your Termux session."
