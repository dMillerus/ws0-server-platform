#!/bin/bash

# Quick test version
set -euo pipefail
OUTPUT_FILE="SERVER_DOCUMENTATION.md"

echo "# Server Documentation Test" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "## System Overview" >> "$OUTPUT_FILE"
echo "- Hostname: $(hostname)" >> "$OUTPUT_FILE"
echo "- Date: $(date)" >> "$OUTPUT_FILE"
echo "- OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "## Packages" >> "$OUTPUT_FILE"
echo "Total packages: $(pacman -Q | wc -l)" >> "$OUTPUT_FILE"

echo "Documentation generated successfully!"
