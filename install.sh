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
if [ -d "$SKILLS_DIR/prd_decomposer" ]; then
  echo "⚠  prd_decomposer already exists — skipping."
else
  cp -r "$REPO_DIR/prd_decomposer" "$SKILLS_DIR/prd_decomposer"
  echo "✓  prd_decomposer → $SKILLS_DIR/prd_decomposer"
fi

# prd_executor
if [ -d "$SKILLS_DIR/prd_executor" ]; then
  echo "⚠  prd_executor already exists — skipping."
else
  cp -r "$REPO_DIR/prd_executor" "$SKILLS_DIR/prd_executor"
  echo "✓  prd_executor → $SKILLS_DIR/prd_executor"
fi

echo ""
echo "Done. Restart Claude Code in $TARGET to activate the skills."
