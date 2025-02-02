# Termux-LocalHost

This script simplifies the process of serving local directories using PHP's built-in web server on Termux for Android. It creates a convenient `localhost` command that prompts for a directory path or accepts it as an argument, then starts the PHP server for that directory on port 8080.

## Features

* Creates a `localhost` command (alias).
* Prompts for a directory path if none is provided as an argument.
* Accepts a directory path as a command-line argument.
* Checks if the provided directory exists before starting the server.
* Starts the PHP server on port 8080.
* Provides clear instructions on how to stop the server.

## Installation

Update & Upgrade Packages
```
apt update && apt upgrade -y
```

Install Required Packages
```
apt install git -y && apt install bash -y
```

Installation
```
cd $Home && git clone https://github.com/y-nabeelxd/Termux-LocalHost && cd Termux-LocalHost && chmod +x install.sh && bash install.sh && cd $Home && rm -rf Termux-LocalHost
```

**Usage**

Starting a Local Server (Interactive)
```
localhost
```
If you run the `localhost` command without any arguments, the script will prompt you to enter the directory path you want to serve.


Starting a Local Server (Direct Path)
```
localhost /path/to/your/directory
```
You can provide the directory path directly as an argument to the localhost command.


Stopping the Server
The script will provide the command to stop the server when it starts:
```
pkill -f 'php -S localhost:8080'
```

You can also create an alias for this command for easier use. Add the following line to your `~/.bashrc` or `~/.zshrc` file:
```
alias stoplocal='pkill -f "php -S localhost:8080"'
```

Then, source the file (source `~/.bashrc` or source `~/.zshrc`) or open a new terminal session. Now you can stop the server by simply typing:
```
stoplocal
```


### Important Considerations
 * Port 8080: The server always starts on port 8080. If another process is using this port, the script will not be able to start the server.
 * Directory Existence: The script checks if the provided directory exists. If it doesn't, the server will not start, and an error message will be displayed.
 * Termux Permissions: Ensure that Termux has the necessary permissions to access the directory you are trying to serve.
 * Background Process: The PHP server runs as a background process.  If you close the Termux app or your device restarts, the server will be stopped. You will need to start it again.


**Example**
```
localhost /sdcard/my_website  # Serves the directory located at /sdcard/my_website
```



**Disclaimer**

This script is provided for educational purposes and for simplifying local development in Termux. The author is not responsible for any issues or data loss that may occur as a result of using this script. Use it at your own risk.
