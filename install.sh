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

  else
    path="$1"
    if ! dir_exists "$path"; then
      echo "Error: Directory '$path' does not exist."
      return 1
    fi
    start_server "$path"
  fi
}


if [ -f ~/.zshrc ]; then
  CONFIG_FILE=~/.zshrc
else
  CONFIG_FILE=~/.bashrc
fi

echo "alias localhost='localhost'" >> "$CONFIG_FILE"
echo "alias stoplocal='stop_localhost'" >> "$CONFIG_FILE"
source "$CONFIG_FILE"

echo "Installation complete.  'localhost' and 'stoplocal' commands are now available."

