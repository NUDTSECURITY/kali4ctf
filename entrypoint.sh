#!/bin/bash
set -e

echo "[*] Starting Kali MCP Docker..."

if command -v kali-server-mcp > /dev/null 2>&1; then
    kali-server-mcp --ip 0.0.0.0 &
elif command -v mcp-server > /dev/null 2>&1; then
    mcp-server &
elif command -v mcp-kali-server > /dev/null 2>&1; then
    mcp-kali-server &
else
    echo "[!] mcp-kali-server not found, running idle"
    tail -f /dev/null
    exit 0
fi

sleep 3
echo "[+] Kali MCP Server ready on 0.0.0.0:5000"

# Keep container running; pass through any additional command
if [ $# -gt 0 ]; then
    exec "$@"
else
    tail -f /dev/null
fi
