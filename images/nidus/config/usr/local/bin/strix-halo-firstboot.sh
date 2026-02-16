#!/bin/bash
# Set tuned profile for AI/GPU workloads (runs once on first boot)
MARKER="/var/lib/strix-halo-configured"
if [ ! -f "$MARKER" ]; then
    # Wait for tuned to be ready
    sleep 5
    tuned-adm profile accelerator-performance
    echo "$(date): accelerator-performance profile set" > "$MARKER"
fi
