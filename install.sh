#!/usr/bin/env bash

set -e

REPO="https://raw.githubusercontent.com/mkarmannyi-ui/ascii-movie/main"
INSTALL_DIR="$HOME/.local/share/ascii-movie"
BIN_DIR="$HOME/.local/bin"

echo "Installing ascii-movie..."

mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"

echo "Downloading movie..."

curl -fL "$REPO/movie.dat" -o "$INSTALL_DIR/movie.dat"

cat > "$BIN_DIR/ascii-movie" << 'EOF'
#!/usr/bin/env python3

import json
import os
import sys
import time
import shutil

MOVIE = os.path.expanduser(
    "~/.local/share/ascii-movie/movie.dat"
)

if not os.path.exists(MOVIE):
    print("ascii-movie: movie.dat not found.")
    sys.exit(1)

with open(MOVIE, "r", encoding="utf-8") as f:
    movie = json.load(f)

frames = movie["frames"]
fps = movie["fps"]
delay = 1.0 / fps

terminal = shutil.get_terminal_size()

sys.stdout.write("\033[2J\033[H\033[?25l")
sys.stdout.flush()

try:
    for frame in frames:
        lines = frame.split("\n")
        width = max(len(line) for line in lines)

        if width < terminal.columns:
            left = (terminal.columns - width) // 2

            frame = "\n".join(
                (" " * left) + line
                for line in lines
            )

        sys.stdout.write("\033[H")
        sys.stdout.write(frame)
        sys.stdout.flush()

        time.sleep(delay)

except KeyboardInterrupt:
    pass

finally:
    sys.stdout.write("\033[?25h\033[0m\n")
    sys.stdout.flush()
EOF

chmod +x "$BIN_DIR/ascii-movie"

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    SHELL_CONFIG="$HOME/.bashrc"

    if [ -n "$ZSH_VERSION" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    fi

    if ! grep -q 'HOME/.local/bin' "$SHELL_CONFIG" 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_CONFIG"
    fi

    export PATH="$BIN_DIR:$PATH"
fi

echo
echo "================================"
echo " ascii-movie installed!"
echo "================================"
echo
echo "Run:"
echo
echo "    ascii-movie"
echo
