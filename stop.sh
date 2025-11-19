#!/bin/bash

echo "🛑 Stopping Fathom-DeepResearch..."

# Stop tool server
if [ -f tool_server.pid ]; then
    kill $(cat tool_server.pid) 2>/dev/null || true
    rm -f tool_server.pid
    echo "   ✓ Tool server stopped"
fi

# Stop Docker containers
docker-compose down
echo "   ✓ vLLM containers stopped"

echo ""
echo "✅ All services stopped"
