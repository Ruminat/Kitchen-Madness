#!/usr/bin/env bash
# Install project git hooks into .git/hooks (no git config changes).
# Usage: ./tools/install-git-hooks.sh

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$ROOT/.githooks/pre-commit"
TARGET="$ROOT/.git/hooks/pre-commit"

if [[ ! -f "$SOURCE" ]]; then
	echo "Missing hook source: $SOURCE" >&2
	exit 1
fi

mkdir -p "$ROOT/.git/hooks"
cp "$SOURCE" "$TARGET"
chmod +x "$TARGET"

echo "Installed pre-commit hook -> .git/hooks/pre-commit"
echo "On master branch, commits will run tools/codecheck."
