#!/bin/bash
# prd-workflow install script
#
# Installs prd_decomposer and prd_executor skills into a Claude Code project.
#
# Usage:   bash install.sh [target_project_path]
# Default: current directory (run from your project root)

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-.}"
SKILLS_DIR="$TARGET/.claude/skills"

echo "Installing prd-workflow skills to: $SKILLS_DIR"
echo ""

mkdir -p "$SKILLS_DIR"

# prd_decomposer
rm -rf "$SKILLS_DIR/prd_decomposer"
cp -r "$REPO_DIR/prd_decomposer" "$SKILLS_DIR/prd_decomposer"
echo "✓  prd_decomposer → $SKILLS_DIR/prd_decomposer"

# prd_executor
rm -rf "$SKILLS_DIR/prd_executor"
cp -r "$REPO_DIR/prd_executor" "$SKILLS_DIR/prd_executor"
echo "✓  prd_executor → $SKILLS_DIR/prd_executor"

echo ""
echo "Done. Restart Claude Code in $TARGET to activate the skills."
