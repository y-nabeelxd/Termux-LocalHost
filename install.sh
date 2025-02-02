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


cat << EOF > "$PREFIX/bin/local"
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
    echo "Usage: local [start] [path] or local stop"
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

chmod +x "$PREFIX/bin/local"

if [ -f ~/.zshrc ]; then
  CONFIG_FILE=~/.zshrc
else
  CONFIG_FILE=~/.bashrc
fi

echo "alias localhost='$PREFIX/bin/local start'" >> "$CONFIG_FILE"
echo "alias stoplocal='$PREFIX/bin/local stop'" >> "$CONFIG_FILE"
source "$CONFIG_FILE"

clear
echo "Installation complete. 'localhost' and 'stoplocal' commands are now available."
sleep 3
