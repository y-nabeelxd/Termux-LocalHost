#!/bin/bash

LOCALHOST_PORT="8080"

dir_exists() {
  if [ -d "$1" ]; then
    return 0
  else
    return 1
  fi
}

start_server() {
  php -S localhost:"$LOCALHOST_PORT" -t "$1" > /dev/null 2>&1 &
  echo "Serving '$1' on http://localhost:$LOCALHOST_PORT"
  echo "To stop: stoplocal"
}

stop_localhost() {
  pkill -f "php -S localhost:$LOCALHOST_PORT"
  if [ $? -eq 0 ]; then
    echo "Stopped localhost server."
  else
    echo "No localhost server found running."
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


cat << EOF > "$BIN_DIR/local"
#!/bin/bash

LOCALHOST_PORT="$LOCALHOST_PORT"

dir_exists() {
  if [ -d "\$1" ]; then
    return 0
  else
    return 1
  fi
}

start_server() {
  php -S localhost:"\$LOCALHOST_PORT" -t "\$1" > /dev/null 2>&1 &
  echo "Serving '\$1' on http://localhost:\$LOCALHOST_PORT"
  echo "To stop: stoplocal"
}

stop_localhost() {
  pkill -f "php -S localhost:\"\$LOCALHOST_PORT\""
  if [ \$? -eq 0 ]; then
    echo "Stopped localhost server."
  else
    echo "No localhost server found running."
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
  localhost "\$2"
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
echo "Remember to restart Termux or source your shell config file for changes to take effect in new sessions."
sleep 5
