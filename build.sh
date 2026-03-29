#!/usr/bin/env bash
# Build an AirTraffic MCP server to a native binary
# Usage: ./build.sh <server.airl> [-o output]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
G3="${G3:-$HOME/repos/AIRL/g3}"

if [[ $# -lt 1 ]]; then
    echo "Usage: ./build.sh <server.airl> [-o output]"
    echo "  server.airl: Your MCP server source file"
    echo "  -o output:   Output binary name (default: server)"
    exit 1
fi

SERVER_FILE="$1"
shift

# Parse -o flag
OUTPUT="server"
while [[ $# -gt 0 ]]; do
    case "$1" in
        -o) OUTPUT="$2"; shift 2 ;;
        *) echo "Unknown flag: $1"; exit 1 ;;
    esac
done

if [[ ! -x "$G3" ]]; then
    echo "Error: g3 compiler not found at $G3"
    echo "Build it: cd ~/repos/AIRL && bash scripts/build-g3.sh"
    exit 1
fi

if [[ ! -f "$SERVER_FILE" ]]; then
    echo "Error: Server file not found: $SERVER_FILE"
    exit 1
fi

echo "Building AirTraffic server: $SERVER_FILE → $OUTPUT"

"$G3" \
    "$SCRIPT_DIR/src/transport.airl" \
    "$SCRIPT_DIR/src/jsonrpc.airl" \
    "$SCRIPT_DIR/src/schema.airl" \
    "$SCRIPT_DIR/src/airtraffic.airl" \
    "$SERVER_FILE" \
    -o "$OUTPUT"

echo "Built: $OUTPUT ($(du -h "$OUTPUT" | cut -f1))"
