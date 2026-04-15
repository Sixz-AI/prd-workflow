#!/bin/bash

# Usage: ./generate_readme.sh <target_dir> <feature_name>

TARGET_DIR="$1"
FEATURE_NAME="$2"

if [ -z "$TARGET_DIR" ] || [ -z "$FEATURE_NAME" ]; then
  echo "Error: Missing arguments."
  echo "Usage: ./generate_readme.sh <target_dir> \"<feature_name>\""
  exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATE_FILE="$SCRIPT_DIR/../resources/README_template.md"
OUTPUT_FILE="$TARGET_DIR/README.md"

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "Error: Template file not found at $TEMPLATE_FILE"
  exit 1
fi

# Ensure target directory exists
mkdir -p "$TARGET_DIR"

# Copy template and replace [Feature Name] with actual feature name
sed "s/\[Feature Name\]/$FEATURE_NAME/g" "$TEMPLATE_FILE" > "$OUTPUT_FILE"

echo "Successfully generated $OUTPUT_FILE"
