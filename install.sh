#!/bin/bash

find_available_port() {
    local port=$1
    while true; do
        if ! nc -z localhost "$port" &>/dev/null; then
            echo "$port"
            return
        fi
        ((port++))
    done
}

dir_exists() {
    if [ -d "$1" ]; then
        return 0
    else
        return 1
    fi
}

start_server() {
    local port=$(find_available_port "$LOCALHOST_PORT")
    
    if ! nc -z localhost "$port" &>/dev/null; then
        if command -v termux-setup-storage &>/dev/null; then
            if ! termux-fix-shebang "$BIN_DIR/localhost" &>/dev/null; then
                echo "Attempting to open port $port..."
                termux-chroot -e echo "Opening port $port" || true
            fi
        fi
    fi
    
    php -S localhost:"$port" -t "$1" > /dev/null 2>&1 &
    echo "Serving '$1' on http://localhost:$port"
    echo "To stop the server, run: stoplocal"
    
    echo "$port" > /tmp/localhost_port
}

stop_localhost() {
    local port_file="/tmp/localhost_port"
    if [ -f "$port_file" ]; then
        local port=$(cat "$port_file")
        pkill -f "php -S localhost:$port"
        if [ $? -eq 0 ]; then
            echo "Stopped localhost server on port $port."
            rm "$port_file"
        else
            echo "No localhost server found running on port $port."
        fi
    else
        echo "No localhost server found running (no port information available)."
        echo "You can try: pkill -f 'php -S localhost:'"
    fi
}

localhost() {
    if [ "$1" == "stop" ]; then
        stop_localhost
        return
    fi

    if [ -z "$1" ]; then
        echo "Please provide the directory path you want to serve."
        echo "Example: localhost ~/my_website"
        return 1
    fi

    if ! dir_exists "$1"; then
        echo "Error: Directory '$1' does not exist."
        return 1
    fi

    start_server "$1"
}

if [ -w "$PREFIX/bin" ]; then
    BIN_DIR="$PREFIX/bin"
elif [ -w "$HOME/bin" ]; then
    BIN_DIR="$HOME/bin"
    export PATH="$BIN_DIR:$PATH"
    echo "Adding $BIN_DIR to PATH"
else
    echo "Neither $PREFIX/bin nor $HOME/bin are writable. Cannot proceed."
    exit 1
fi

LOCALHOST_PORT="8080"

cat << EOF > "$BIN_DIR/localhost"
#!/bin/bash

find_available_port() {
    local port=\$1
    while true; do
        if ! nc -z localhost "\$port" &>/dev/null; then
            echo "\$port"
            return
        fi
        ((port++))
    done
}

dir_exists() {
    if [ -d "\$1" ]; then
        return 0
    else
        return 1
    fi
}

start_server() {
    local port=\$(find_available_port "$LOCALHOST_PORT")
    
    if ! nc -z localhost "\$port" &>/dev/null; then
        if command -v termux-setup-storage &>/dev/null; then
            if ! termux-fix-shebang "$BIN_DIR/localhost" &>/dev/null; then
                echo "Attempting to open port \$port..."
                termux-chroot -e echo "Opening port \$port" || true
            fi
        fi
    fi
    
    php -S localhost:"\$port" -t "\$1" > /dev/null 2>&1 &
    echo "Serving '\$1' on http://localhost:\$port"
    echo "To stop the server, run: stoplocal"
    
    echo "\$port" > /tmp/localhost_port
}

stop_localhost() {
    local port_file="/tmp/localhost_port"
    if [ -f "\$port_file" ]; then
        local port=\$(cat "\$port_file")
        pkill -f "php -S localhost:\$port"
        if [ \$? -eq 0 ]; then
            echo "Stopped localhost server on port \$port."
            rm "\$port_file"
        else
            echo "No localhost server found running on port \$port."
        fi
    else
        echo "No localhost server found running (no port information available)."
        echo "You can try: pkill -f 'php -S localhost:'"
    fi
}

if [ -z "\$1" ]; then
    echo "Usage: localhost [path]"
    echo "       localhost stop"
    exit 1
fi

if [ "\$1" == "stop" ]; then
    stop_localhost
    exit 0
fi

if ! dir_exists "\$1"; then
    echo "Error: Directory '\$1' does not exist."
    exit 1
fi

start_server "\$1"
EOF

chmod +x "$BIN_DIR/localhost"

if [ -f ~/.zshrc ]; then
    CONFIG_FILE=~/.zshrc
    PROFILE_FILE=~/.zprofile
else
    CONFIG_FILE=~/.bashrc
    PROFILE_FILE=~/.bash_profile
fi

echo "alias stoplocal='localhost stop'" >> "$CONFIG_FILE"
source "$CONFIG_FILE"
echo "source $CONFIG_FILE" >> "$PROFILE_FILE"

clear
echo "Installation complete. 'localhost' and 'stoplocal' commands are now available."
echo "Usage:"
echo "  localhost /path/to/directory    # Start server for directory"
echo "  stoplocal                       # Stop running server"
echo ""
echo "Features:"
echo "- Automatically finds available port starting from 8080"
echo "- Attempts to open port if not accessible"
echo "- Properly tracks running server for clean stop"
echo ""
echo "Remember to restart Termux or source your shell config file for changes to take effect in new sessions."
sleep 5
