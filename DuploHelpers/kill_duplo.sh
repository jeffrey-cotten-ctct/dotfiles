#!/usr/bin/env bash
# Finds and kills all running Duplo processes

PATTERN="duplo"
PIDS=$(pgrep -i "$PATTERN")

if [ -z "$PIDS" ]; then
    echo "No Duplo processes found."
    exit 0
fi

echo "Found Duplo process(es):"
pgrep -a -i "$PATTERN"

for PID in $PIDS; do
    echo "Killing PID $PID..."
    kill "$PID" && echo "  Sent SIGTERM to $PID" || echo "  Failed to kill $PID"
done

# Give processes a moment to terminate gracefully
sleep 2

# Force kill any remaining
REMAINING=$(pgrep -i "$PATTERN")
if [ -n "$REMAINING" ]; then
    echo "Force killing remaining processes..."
    for PID in $REMAINING; do
        kill -9 "$PID" && echo "  Force killed PID $PID" || echo "  Failed to force kill $PID"
    done
fi

echo "Done."
