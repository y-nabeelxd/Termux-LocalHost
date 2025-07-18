#!/bin/bash

# Termux-LocalHost Installer
# Version: 2.3
# Author: Y-Nabeel
# GitHub: https://github.com/y-nabeelxd/Termux-LocalHost

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

create_default_index() {
    local dir=$1
    local index_file="$dir/index.html"
    
    if [ ! -f "$index_file" ] && [ ! -f "$dir/index.php" ] && [ ! -f "$dir/index.htm" ]; then
        cat << 'EOF' > "$index_file"
<!DOCTYPE html>
<html lang="en" data-theme="auto">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Termux LocalHost</title>
    <style>
        :root {
            --bg-color: #f5f5f5;
            --text-color: #333;
            --primary-color: #4285f4;
            --secondary-color: #f1f1f1;
            --border-color: #ddd;
        }
        
        [data-theme="dark"] {
            --bg-color: #1a1a1a;
            --text-color: #f1f1f1;
            --primary-color: #8ab4f8;
            --secondary-color: #2d2d2d;
            --border-color: #444;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 0;
            background-color: var(--bg-color);
            color: var(--text-color);
            transition: background-color 0.3s, color 0.3s;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 2rem;
        }
        
        header {
            text-align: center;
            margin-bottom: 2rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid var(--border-color);
        }
        
        h1 {
            color: var(--primary-color);
            margin-bottom: 0.5rem;
        }
        
        .theme-switch {
            position: fixed;
            top: 1rem;
            right: 1rem;
            background: var(--secondary-color);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 5px;
            cursor: pointer;
            display: flex;
            align-items: center;
        }
        
        .theme-icon {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            margin: 0 5px;
        }
        
        .sun {
            background: #f39c12;
        }
        
        .moon {
            background: #3498db;
        }
        
        .info-box {
            background-color: var(--secondary-color);
            border: 1px solid var(--border-color);
            border-radius: 5px;
            padding: 1rem;
            margin-bottom: 1.5rem;
        }
        
        .directory-list {
            margin-top: 1.5rem;
        }
        
        .directory-list ul {
            list-style-type: none;
            padding: 0;
        }
        
        .directory-list li {
            padding: 0.5rem 0;
            border-bottom: 1px dashed var(--border-color);
            display: flex;
            align-items: center;
        }
        
        .directory-list li:last-child {
            border-bottom: none;
        }
        
        .directory-list a {
            color: var(--primary-color);
            text-decoration: none;
            display: flex;
            align-items: center;
            flex-grow: 1;
        }
        
        .directory-list a:hover {
            text-decoration: underline;
        }
        
        .file-icon {
            margin-right: 8px;
            font-size: 1.1em;
        }
        
        footer {
            text-align: center;
            margin-top: 2rem;
            padding-top: 1rem;
            border-top: 1px solid var(--border-color);
            font-size: 0.9rem;
            color: #777;
        }
        
        .loading {
            color: var(--primary-color);
            font-style: italic;
        }
        
        .error {
            color: #e74c3c;
        }
    </style>
</head>
<body>
    <div class="theme-switch" onclick="toggleTheme()">
        <div class="theme-icon sun">☀️</div>
        <div class="theme-icon moon">🌙</div>
    </div>
    
    <div class="container">
        <header>
            <h1>Termux LocalHost</h1>
            <p>Your local development server is running!</p>
        </header>
        
        <div class="info-box">
            <h2>Welcome to your local server</h2>
            <p>This is a default page because no index file was found in this directory.</p>
            <p>To replace this page, create an <code>index.html</code>, <code>index.php</code>, or <code>index.htm</code> file in this directory.</p>
        </div>
        
        <div class="directory-list">
            <h3>Directory Contents:</h3>
            <div id="file-list">
                <p class="loading">Loading directory contents...</p>
            </div>
        </div>
        
        <footer>
            <p>Served by Termux-LocalHost | Port: <span id="port-number">PORT_PLACEHOLDER</span></p>
        </footer>
    </div>
    
    <script>
        // List files in directory
        function listFiles() {
            const fileList = document.getElementById('file-list');
            
            fetch(window.location.pathname)
            .then(response => {
                if (!response.ok) {
                    throw new Error('Failed to load directory');
                }
                return response.text();
            })
            .then(html => {
                const parser = new DOMParser();
                const doc = parser.parseFromString(html, 'text/html');
                const links = Array.from(doc.querySelectorAll('a'))
                    .filter(link => {
                        const href = link.getAttribute('href');
                        return href && !['../', './'].includes(href) && 
                               !href.startsWith('?') && 
                               !href.startsWith(window.location.pathname);
                    });

                if (links.length > 0) {
                    let listHTML = '<ul>';
                    
                    links.forEach(link => {
                        const href = link.getAttribute('href');
                        const text = link.textContent;
                        const isDirectory = href.endsWith('/');
                        const icon = isDirectory ? '📁' : '📄';
                        const fullPath = window.location.pathname + 
                                         (window.location.pathname.endsWith('/') ? '' : '/') + 
                                         href;
                        
                        listHTML += `
                            <li>
                                <a href="${fullPath}">
                                    <span class="file-icon">${icon}</span>
                                    <span>${text}</span>
                                </a>
                            </li>`;
                    });
                    
                    listHTML += '</ul>';
                    fileList.innerHTML = listHTML;
                } else {
                    fileList.innerHTML = '<p>No files found in this directory</p>';
                }
            })
            .catch(error => {
                console.error('Error:', error);
                fileList.innerHTML = '<p class="error">Directory listing not available</p>';
            });
        }

        // Toggle between light and dark theme
        function toggleTheme() {
            const html = document.documentElement;
            const currentTheme = html.getAttribute('data-theme');
            const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
            html.setAttribute('data-theme', newTheme);
            localStorage.setItem('theme', newTheme);
        }
        
        // Check for saved theme preference
        function checkTheme() {
            const savedTheme = localStorage.getItem('theme') || 'auto';
            const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
            
            let theme = savedTheme;
            if (savedTheme === 'auto') {
                theme = prefersDark ? 'dark' : 'light';
            }
            
            document.documentElement.setAttribute('data-theme', theme);
        }
        
        // Display current port number
        function showPort() {
            const port = window.location.port || '80';
            document.getElementById('port-number').textContent = port;
        }
        
        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            checkTheme();
            listFiles();
            showPort();
        });
    </script>
</body>
</html>
EOF
        echo -e "${YELLOW}Created default index.html in ${GREEN}$dir${NC}"
    fi
}

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
    local port_file="$HOME/.localhost_port"
    
    create_default_index "$1"
    
    if ! nc -z localhost "$port" &>/dev/null; then
        if command -v termux-setup-storage &>/dev/null; then
            echo -e "${YELLOW}Attempting to open port $port...${NC}"
            termux-chroot -e echo "Opening port $port" || true
        fi
    fi
    
    php -S localhost:"$port" -t "$1" > /dev/null 2>&1 &
    
    echo "$port" > "$port_file"
    chmod 600 "$port_file"
    
    echo -e "${GREEN}Serving '${YELLOW}$1${GREEN}' on ${YELLOW}http://localhost:$port${NC}"
    echo -e "To stop the server, run: ${YELLOW}stoplocal${NC}"
}

stop_localhost() {
    local port_file="$HOME/.localhost_port"
    if [ -f "$port_file" ]; then
        local port=$(cat "$port_file")
        pkill -f "php -S localhost:$port"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Stopped localhost server on port ${YELLOW}$port${NC}"
            rm "$port_file"
        else
            echo -e "${RED}No localhost server found running on port ${YELLOW}$port${NC}"
        fi
    else
        echo -e "${RED}No localhost server found running (no port information available)${NC}"
        echo -e "You can try: ${YELLOW}pkill -f 'php -S localhost:'${NC}"
    fi
}

localhost() {
    if [ "$1" == "stop" ]; then
        stop_localhost
        return
    fi

    if [ -z "$1" ]; then
        echo -e "${RED}Error: Please provide directory path${NC}"
        echo -e "Usage: ${YELLOW}localhost [path]${NC}"
        echo -e "       ${YELLOW}localhost stop${NC}"
        return 1
    fi

    if ! dir_exists "$1"; then
        echo -e "${RED}Error: Directory '${YELLOW}$1${RED}' does not exist${NC}"
        return 1
    fi

    start_server "$1"
}

if [ -w "$PREFIX/bin" ]; then
    BIN_DIR="$PREFIX/bin"
elif [ -w "$HOME/bin" ]; then
    BIN_DIR="$HOME/bin"
    export PATH="$BIN_DIR:$PATH"
    echo -e "${YELLOW}Adding $BIN_DIR to PATH${NC}"
else
    echo -e "${RED}Neither $PREFIX/bin nor $HOME/bin are writable. Cannot proceed.${NC}"
    exit 1
fi

LOCALHOST_PORT="8080"

cat << EOF > "$BIN_DIR/localhost"
#!/bin/bash

# Do not edit manually - Generated by installer

port_file="\$HOME/.localhost_port"

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
    
    # Create default index.html if needed
    if [ ! -f "\$1/index.html" ] && [ ! -f "\$1/index.php" ] && [ ! -f "\$1/index.htm" ]; then
        cat << 'EOHTML' > "\$1/index.html"
<!DOCTYPE html>
<html lang="en" data-theme="auto">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Termux LocalHost</title>
    <style>
        :root {
            --bg-color: #f5f5f5;
            --text-color: #333;
            --primary-color: #4285f4;
            --secondary-color: #f1f1f1;
            --border-color: #ddd;
        }
        
        [data-theme="dark"] {
            --bg-color: #1a1a1a;
            --text-color: #f1f1f1;
            --primary-color: #8ab4f8;
            --secondary-color: #2d2d2d;
            --border-color: #444;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 0;
            background-color: var(--bg-color);
            color: var(--text-color);
            transition: background-color 0.3s, color 0.3s;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 2rem;
        }
        
        header {
            text-align: center;
            margin-bottom: 2rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid var(--border-color);
        }
        
        h1 {
            color: var(--primary-color);
            margin-bottom: 0.5rem;
        }
        
        .theme-switch {
            position: fixed;
            top: 1rem;
            right: 1rem;
            background: var(--secondary-color);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 5px;
            cursor: pointer;
            display: flex;
            align-items: center;
        }
        
        .theme-icon {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            margin: 0 5px;
        }
        
        .sun {
            background: #f39c12;
        }
        
        .moon {
            background: #3498db;
        }
        
        .info-box {
            background-color: var(--secondary-color);
            border: 1px solid var(--border-color);
            border-radius: 5px;
            padding: 1rem;
            margin-bottom: 1.5rem;
        }
        
        .directory-list {
            margin-top: 1.5rem;
        }
        
        .directory-list ul {
            list-style-type: none;
            padding: 0;
        }
        
        .directory-list li {
            padding: 0.5rem 0;
            border-bottom: 1px dashed var(--border-color);
            display: flex;
            align-items: center;
        }
        
        .directory-list li:last-child {
            border-bottom: none;
        }
        
        .directory-list a {
            color: var(--primary-color);
            text-decoration: none;
            display: flex;
            align-items: center;
            flex-grow: 1;
        }
        
        .directory-list a:hover {
            text-decoration: underline;
        }
        
        .file-icon {
            margin-right: 8px;
            font-size: 1.1em;
        }
        
        footer {
            text-align: center;
            margin-top: 2rem;
            padding-top: 1rem;
            border-top: 1px solid var(--border-color);
            font-size: 0.9rem;
            color: #777;
        }
        
        .loading {
            color: var(--primary-color);
            font-style: italic;
        }
        
        .error {
            color: #e74c3c;
        }
    </style>
</head>
<body>
    <div class="theme-switch" onclick="toggleTheme()">
        <div class="theme-icon sun">☀️</div>
        <div class="theme-icon moon">🌙</div>
    </div>
    
    <div class="container">
        <header>
            <h1>Termux LocalHost</h1>
            <p>Your local development server is running!</p>
        </header>
        
        <div class="info-box">
            <h2>Welcome to your local server</h2>
            <p>This is a default page because no index file was found in this directory.</p>
            <p>To replace this page, create an <code>index.html</code>, <code>index.php</code>, or <code>index.htm</code> file in this directory.</p>
        </div>
        
        <div class="directory-list">
            <h3>Directory Contents:</h3>
            <div id="file-list">
                <p class="loading">Loading directory contents...</p>
            </div>
        </div>
        
        <footer>
            <p>Served by Termux-LocalHost | Port: <span id="port-number">PORT_PLACEHOLDER</span></p>
        </footer>
    </div>
    
    <script>
        // List files in directory
        function listFiles() {
            const fileList = document.getElementById('file-list');
            
            fetch(window.location.pathname)
            .then(response => {
                if (!response.ok) {
                    throw new Error('Failed to load directory');
                }
                return response.text();
            })
            .then(html => {
                const parser = new DOMParser();
                const doc = parser.parseFromString(html, 'text/html');
                const links = Array.from(doc.querySelectorAll('a'))
                    .filter(link => {
                        const href = link.getAttribute('href');
                        return href && !['../', './'].includes(href) && 
                               !href.startsWith('?') && 
                               !href.startsWith(window.location.pathname);
                    });

                if (links.length > 0) {
                    let listHTML = '<ul>';
                    
                    links.forEach(link => {
                        const href = link.getAttribute('href');
                        const text = link.textContent;
                        const isDirectory = href.endsWith('/');
                        const icon = isDirectory ? '📁' : '📄';
                        const fullPath = window.location.pathname + 
                                         (window.location.pathname.endsWith('/') ? '' : '/') + 
                                         href;
                        
                        listHTML += `
                            <li>
                                <a href="${fullPath}">
                                    <span class="file-icon">${icon}</span>
                                    <span>${text}</span>
                                </a>
                            </li>`;
                    });
                    
                    listHTML += '</ul>';
                    fileList.innerHTML = listHTML;
                } else {
                    fileList.innerHTML = '<p>No files found in this directory</p>';
                }
            })
            .catch(error => {
                console.error('Error:', error);
                fileList.innerHTML = '<p class="error">Directory listing not available</p>';
            });
        }

        // Toggle between light and dark theme
        function toggleTheme() {
            const html = document.documentElement;
            const currentTheme = html.getAttribute('data-theme');
            const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
            html.setAttribute('data-theme', newTheme);
            localStorage.setItem('theme', newTheme);
        }
        
        // Check for saved theme preference
        function checkTheme() {
            const savedTheme = localStorage.getItem('theme') || 'auto';
            const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
            
            let theme = savedTheme;
            if (savedTheme === 'auto') {
                theme = prefersDark ? 'dark' : 'light';
            }
            
            document.documentElement.setAttribute('data-theme', theme);
        }
        
        // Display current port number
        function showPort() {
            const port = window.location.port || '80';
            document.getElementById('port-number').textContent = port;
        }
        
        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            checkTheme();
            listFiles();
            showPort();
        });
    </script>
</body>
</html>
EOHTML
    fi
    
    if ! nc -z localhost "\$port" &>/dev/null; then
        if command -v termux-setup-storage &>/dev/null; then
            echo -e "\033[1;33mAttempting to open port \$port...\033[0m"
            termux-chroot -e echo "Opening port \$port" || true
        fi
    fi
    
    php -S localhost:"\$port" -t "\$1" > /dev/null 2>&1 &
    echo "\$port" > "\$port_file"
    chmod 600 "\$port_file"
    
    echo -e "\033[0;32mServing '\033[1;33m\$1\033[0;32m' on \033[1;33mhttp://localhost:\$port\033[0m"
    echo -e "To stop the server, run: \033[1;33mstoplocal\033[0m"
}

stop_localhost() {
    if [ -f "\$port_file" ]; then
        local port=\$(cat "\$port_file")
        pkill -f "php -S localhost:\$port"
        if [ \$? -eq 0 ]; then
            echo -e "\033[0;32mStopped localhost server on port \033[1;33m\$port\033[0m"
            rm "\$port_file"
        else
            echo -e "\033[0;31mNo localhost server found running on port \033[1;33m\$port\033[0m"
        fi
    else
        echo -e "\033[0;31mNo localhost server found running (no port information available)\033[0m"
        echo -e "You can try: \033[1;33mpkill -f 'php -S localhost:'\033[0m"
    fi
}

if [ "\$1" == "stop" ]; then
    stop_localhost
    exit 0
fi

if [ -z "\$1" ]; then
    echo -e "\033[0;31mError: Please provide directory path\033[0m"
    echo -e "Usage: \033[1;33mlocalhost [path]\033[0m"
    echo -e "       \033[1;33mlocalhost stop\033[0m"
    exit 1
fi

if ! dir_exists "\$1"; then
    echo -e "\033[0;31mError: Directory '\033[1;33m\$1\033[0;31m' does not exist\033[0m"
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

if ! grep -q "alias stoplocal=" "$CONFIG_FILE"; then
    echo "alias stoplocal='localhost stop'" >> "$CONFIG_FILE"
fi

source "$CONFIG_FILE" >/dev/null 2>&1
echo "source $CONFIG_FILE" >> "$PROFILE_FILE"

clear
echo -e "${GREEN}╔════════════════════════════════════════╗"
echo -e "║   ${YELLOW}Termux-LocalHost Installation Complete${GREEN}   ║"
echo -e "╚════════════════════════════════════════╝${NC}"
echo -e "\n${YELLOW}Usage:${NC}"
echo -e "  ${GREEN}localhost [path]${NC}    # Start server for directory"
echo -e "  ${GREEN}stoplocal${NC}          # Stop running server"
echo -e "\n${YELLOW}Features:${NC}"
echo -e "  - Automatic light/dark theme switching"
echo -e "  - Working directory listing with icons"
echo -e "  - Beautiful default homepage"
echo -e "  - Automatic port selection (8080+)"
echo -e "  - Easy server management"
echo -e "\n${YELLOW}Examples:${NC}"
echo -e "  ${GREEN}localhost ~/my-website${NC}"
echo -e "  ${GREEN}localhost /sdcard/my-project${NC}"
echo -e "\n${YELLOW}Note:${NC}"
echo -e "- Server starts on first available port from 8080"
echo -e "- Port information is stored in ~/.localhost_port"
echo -e "- Default page appears when no index file exists"
echo -e "\n${YELLOW}Restart Termux or run:${NC} ${GREEN}source $CONFIG_FILE${NC}"
sleep 5
