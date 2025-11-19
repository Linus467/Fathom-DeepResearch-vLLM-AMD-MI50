#!/bin/bash
set -e

echo "🚀 Starting Fathom-DeepResearch on AMD MI50..."
echo ""

# Load environment variables from .env
if [ -f .env ]; then
    echo "📝 Loading environment from .env..."
    source .env
else
    echo "⚠️  Warning: .env file not found, using defaults"
    export OPENAI_API_KEY="dummy-not-used"
    export SERPER_API_KEY="your-key-here"
    export JINA_API_KEY="your-key-here"
fi

# Check if models exist
if [ ! -d "$HOME/models/Fathom-Search-4B" ] || [ ! -d "$HOME/models/Fathom-Synthesizer-4B" ]; then
    echo "❌ Error: Models not found in $HOME/models/"
    exit 1
fi

# Start Docker containers
echo "1️⃣  Starting vLLM containers..."
docker compose up -d

# Wait for models to load
echo "2️⃣  Waiting for models to initialize (45 seconds)..."
sleep 45

# Check endpoints
echo "3️⃣  Checking model endpoints..."
curl -sf http://localhost:8000/v1/models > /dev/null && echo "   ✓ Search model ready" || echo "   ⚠ Search model not ready"
curl -sf http://localhost:8001/v1/models > /dev/null && echo "   ✓ Synthesizer ready" || echo "   ⚠ Synthesizer not ready"

# Start tool server with environment variables
echo "4️⃣  Starting tool server..."
cd ~/Fathom-DeepResearch
source venv/bin/activate 2>/dev/null || python3 -m venv venv && source venv/bin/activate

# Kill existing tool server if running
if [ -f tool_server.pid ]; then
    kill $(cat tool_server.pid) 2>/dev/null || true
    rm -f tool_server.pid
fi

# Start with explicit environment variables
SERPER_API_KEY="$SERPER_API_KEY" \
JINA_API_KEY="$JINA_API_KEY" \
OPENAI_API_KEY="$OPENAI_API_KEY" \
nohup bash serving/host_server.sh 8904 16 "http://localhost:8000" > tool_server.log 2>&1 &

echo $! > tool_server.pid
sleep 5

# Verify tool server is running
if nc -z localhost 8904 2>/dev/null; then
    echo "   ✓ Tool server ready (port 8904)"
else
    echo "   ⚠ Tool server not ready, check tool_server.log"
fi

echo ""
echo "✅ Fathom-DeepResearch is ready!"
echo ""
echo "📊 Services:"
echo "   Search:     http://localhost:8000"
echo "   Synth:      http://localhost:8001"
echo "   Tools:      http://localhost:8904"
echo ""
echo "📝 Run: ./run_inference.sh 'Your question'"
echo ""
echo "🔑 API Keys loaded:"
echo "   SERPER: ${SERPER_API_KEY:0:10}..."
echo "   JINA:   ${JINA_API_KEY:0:10}..."
