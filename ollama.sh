#!/bin/bash

# Wait for the MODEL environment variable to be set
while [ -z "$MODEL" ]; do
  echo "Waiting for MODEL environment variable..."
  sleep 1
done

echo "Using model: $MODEL"

# Check if MODEL2 is defined
if [ -n "$MODEL2" ]; then
  echo "Also using model: $MODEL2"
else
  echo "MODEL2 not defined, skipping second model pull."
fi

echo "Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

# Export OLLAMA_HOST before starting the server
export OLLAMA_HOST=0.0.0.0

echo "Starting Ollama server..."
# Start Ollama server in the background
ollama serve > /ollama.log 2>&1 &

# Wait for the server to be ready
echo "Waiting for Ollama server to start..."
while ! curl -s http://127.0.0.1:11434 > /dev/null; do
  sleep 1
done

echo "Ollama server is up!"

echo "Installing model $MODEL..."
ollama pull "$MODEL"

# Check if MODEL2 is defined before pulling
if [ -n "$MODEL2" ]; then
  echo "Installing model $MODEL2..."
  ollama pull "$MODEL2"
fi

echo "Ollama service is running!"
echo "To interact with the model, use the 'ollama' command."

# Add a slight pause before running the next commands
sleep 2

# List available Ollama models
echo "Listing available Ollama models:"
ollama list

# Add a slight pause
sleep 1

# Show NVIDIA stats
echo "NVIDIA stats:"
nvidia-smi

# Add a final pause before tailing the log
sleep 1

# Keep the container running by tailing the log
tail -f /ollama.log
