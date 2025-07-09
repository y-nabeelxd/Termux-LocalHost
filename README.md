# Termux-LocalHost

This script simplifies the process of serving local directories using PHP's built-in web server on Termux for Android. It creates a convenient `localhost` command that starts the PHP server for a specified directory on an available port (starting from 8080).

## Features

* Creates a `localhost` command for starting the PHP server
* Creates a `stoplocal` command for stopping the server
* Automatically finds an available port starting from 8080
* Checks if the provided directory exists before starting the server
* Provides clear instructions on how to stop the server
* Tracks the running server for clean stop functionality

## Installation

1. Update & Upgrade Packages:
```
apt update && apt upgrade -y
```

2. Install Required Packages:
```
apt install git php -y
```

3. Run the installation:
```
cd $HOME && git clone https://github.com/y-nabeelxd/Termux-LocalHost && cd Termux-LocalHost && chmod +x install.sh && bash install.sh && cd $HOME && rm -rf Termux-LocalHost
```

## Usage

### Starting a Local Server
```
localhost /path/to/your/directory
```
Example:
```
localhost ~/my_website
```

### Stopping the Server
```
stoplocal
```

### Getting Help
If you run `localhost` without arguments, it will show usage instructions.

## Uninstallation
To completely remove Termux-LocalHost:
```
cd $HOME && git clone https://github.com/y-nabeelxd/Termux-LocalHost && cd Termux-LocalHost && stoplocal && clear && chmod +x uninstall.sh && bash uninstall.sh && cd $HOME && rm -rf Termux-LocalHost
```

## Important Notes

* The server starts on the first available port starting from 8080
* The script checks if the provided directory exists before starting
* Termux needs storage permissions to access certain directories
* The server runs as a background process and will stop when Termux closes
* If the default port is busy, the script will automatically try higher ports

## Troubleshooting

If you get "Directory does not exist" errors:
1. Verify the path is correct
2. Ensure Termux has storage permissions
3. Use absolute paths (starting with /) for best results

If the server doesn't start:
1. Make sure PHP is installed (`apt install php`)
2. Check if another process is using the port
3. Try running `termux-setup-storage` if you're serving from /sdcard

## Disclaimer

This script is provided for educational purposes and for simplifying local development in Termux. The author is not responsible for any issues or data loss that may occur as a result of using this script. Use it at your own risk.
