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
            if ! termux-fix-shebang "$BIN_DIR/local" &>/dev/null; then
                echo "Attempting to open port $port..."
                termux-chroot -e echo "Opening port $port" || true
            fi
        fi
    fi
    
    php -S localhost:"$port" -t "$1" > /dev/null 2>&1 &
    echo "Serving '$1' on http://localhost:$port"
    echo "To stop: stoplocal"
    
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
    if [ -z "$1" ]; then
        read -p "Please provide where you want to localhost (give me a path): " path
        if ! dir_exists "$path"; then
            echo "Error: Directory '$path' does not exist."
            return 1
        fi
        start_server "$path"
    elif [ "$1" == "start" ]; then
        path="$2"
        if ! dir_exists "$path"; then
            echo "Error: Directory '$path' does not exist."
            return 1
        fi
        start_server "$path"
    elif [ "$1" == "stop" ]; then
        stop_localhost
    else
        echo "Usage: localhost [start] [path] or localhost stop"
        return 1
    fi
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

cat << EOF > "$BIN_DIR/local"
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
    local port=\$(find_available_port "\$LOCALHOST_PORT")
    
    if ! nc -z localhost "\$port" &>/dev/null; then
        if command -v termux-setup-storage &>/dev/null; then
            if ! termux-fix-shebang "$BIN_DIR/local" &>/dev/null; then
                echo "Attempting to open port \$port..."
                termux-chroot -e echo "Opening port \$port" || true
            fi
        fi
    fi
    
    php -S localhost:"\$port" -t "\$1" > /dev/null 2>&1 &
    echo "Serving '\$1' on http://localhost:\$port"
    echo "To stop: stoplocal or pkill -f 'php -S localhost:'"
    
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

localhost() {
    if [ -z "\$1" ]; then
        read -p "Please provide where you want to localhost (give me a path): " path
        if ! dir_exists "\$path"; then
            echo "Error: Directory '\$path' does not exist."
            return 1
        fi
        start_server "\$path"
    elif [ "\$1" == "start" ]; then
        path="\$2"
        if ! dir_exists "\$path"; then
            echo "Error: Directory '\$path' does not exist."
            return 1
        fi
        start_server "\$path"
    elif [ "\$1" == "stop" ]; then
        stop_localhost
    else
        echo "Usage: local [start|stop] [path]"
        return 1
    fi
}

if [ "\$1" == "" ]; then
    localhost
elif [ "\$1" == "start" ]; then
    localhost start "\$2"
elif [ "\$1" == "stop" ]; then
    stop_localhost
else
    echo "Usage: local [start|stop] [path]"
    exit 1
fi
EOF

chmod +x "$BIN_DIR/local"

if [ -f ~/.zshrc ]; then
    CONFIG_FILE=~/.zshrc
    PROFILE_FILE=~/.zprofile
else
    CONFIG_FILE=~/.bashrc
    PROFILE_FILE=~/.bash_profile
fi

echo "alias localhost='$BIN_DIR/local start'" >> "$CONFIG_FILE"
echo "alias stoplocal='$BIN_DIR/local stop'" >> "$CONFIG_FILE"
source "$CONFIG_FILE"
echo "source $CONFIG_FILE" >> "$PROFILE_FILE"

clear
echo "Installation complete. 'localhost' and 'stoplocal' commands are now available."
echo "Features:"
echo "- Automatically finds available port starting from 8080"
echo "- Attempts to open port if not accessible"
echo "- Properly tracks running server for clean stop"
echo ""
echo "Remember to restart Termux or source your shell config file for changes to take effect in new sessions."
sleep 5
