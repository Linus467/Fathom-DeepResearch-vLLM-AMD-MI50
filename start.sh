#!/bin/bash
set -e

echo "🚀 Starting Fathom-DeepResearch on AMD MI50..."
echo ""

# Check if models exist
if [ ! -d "$HOME/models/Fathom-Search-4B" ] || [ ! -d "$HOME/models/Fathom-Synthesizer-4B" ]; then
    echo "❌ Error: Models not found in $HOME/models/"
    echo "Please download:"
    echo "  - Fathom-Search-4B"
    echo "  - Fathom-Synthesizer-4B"
    exit 1
fi

# Start Docker containers
echo "1️⃣  Starting vLLM containers..."
docker-compose up -d

# Wait for models to load
echo "2️⃣  Waiting for models to initialize (45 seconds)..."
sleep 45

# Check if endpoints are ready
echo "3️⃣  Checking model endpoints..."
if curl -sf http://localhost:8000/v1/models > /dev/null; then
    echo "   ✓ Search model ready (port 8000)"
else
    echo "   ⚠ Search model not ready yet"
fi

if curl -sf http://localhost:8001/v1/models > /dev/null; then
    echo "   ✓ Synthesizer model ready (port 8001)"
else
    echo "   ⚠ Synthesizer model not ready yet"
fi

# Activate venv and start tool server
echo "4️⃣  Starting tool server..."
cd ~/Fathom-DeepResearch
source venv/bin/activate 2>/dev/null || python3 -m venv venv && source venv/bin/activate

export OPENAI_API_KEY="${OPENAI_API_KEY:-dummy-not-used}"
export SERPER_API_KEY="${SERPER_API_KEY:-your-key-here}"

nohup bash serving/host_server.sh 8904 16 "http://localhost:8000" > tool_server.log 2>&1 &
echo $! > tool_server.pid

sleep 3

echo ""
echo "✅ Fathom-DeepResearch is ready!"
echo ""
echo "📊 Service Status:"
echo "   Search Model:  http://localhost:8000"
echo "   Synthesizer:   http://localhost:8001"
echo "   Tool Server:   http://localhost:8904"
echo ""
echo "📝 Run inference:"
echo "   python3 inference.py \\"
echo "     --question 'Your question here' \\"
echo "     --model-url http://localhost:8000 \\"
echo "     --executors http://localhost:8904 \\"
echo "     --tokenizer FractalAIResearch/Fathom-Search-4B \\"
echo "     --summary-llm http://localhost:8001 \\"
echo "     --deepresearch"
echo ""
echo "📋 View logs:"
echo "   docker-compose logs -f vllm-search"
echo "   docker-compose logs -f vllm-synth"
echo "   tail -f tool_server.log"
