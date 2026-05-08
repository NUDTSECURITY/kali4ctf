#!/usr/bin/env bash
# SessionStart hook: ensure Kali MCP Docker container is healthy.
# Runs before any MCP tool is available.

set -uo pipefail

KALI_URL="http://localhost:5000/health"
MAX_WAIT=30
CHECK_INTERVAL=2
CONTAINER_NAME="kali-mcp"
IMAGE="kali-mcp:latest"

health_ok() {
    curl -sf --max-time 3 "$KALI_URL" >/dev/null 2>&1
}

get_container_status() {
    docker inspect -f '{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null || true
}

if health_ok; then
    echo '{"systemMessage":"Kali MCP server is healthy and ready."}'
    exit 0
fi

state="$(get_container_status)"

if [ -z "$state" ]; then
    echo "[kali-hook] No container found — starting from image $IMAGE..." >&2
    docker run -d --name "$CONTAINER_NAME" -p 5000:5000 "$IMAGE" >/dev/null
elif [ "$state" = "running" ]; then
    :  # already running, just waiting for health
elif [ "$state" = "paused" ]; then
    echo "[kali-hook] Container is paused — unpausing..." >&2
    docker unpause "$CONTAINER_NAME" >/dev/null
else
    echo "[kali-hook] Container is $state — removing and recreating..." >&2
    docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1
    docker run -d --name "$CONTAINER_NAME" -p 5000:5000 "$IMAGE" >/dev/null
fi

elapsed=0
while ! health_ok && [ $elapsed -lt $MAX_WAIT ]; do
    sleep "$CHECK_INTERVAL"
    elapsed=$((elapsed + CHECK_INTERVAL))
done

if ! health_ok; then
    echo '{"systemMessage":"WARNING: Kali MCP container not healthy after '"${MAX_WAIT}"'s. Tools may fail."}'
    exit 0
fi

echo '{"systemMessage":"Kali MCP container started and healthy."}'
exit 0
