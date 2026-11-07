#!/usr/bin/env bash
# S-li Linux WSL & Git Bash One-Click Installer
# Designed for Shell Line Interface

set -e

SLI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "========================================="
echo "          S-li Shell 安裝程式            "
echo "========================================="
echo ""

TARGET_FILE="$HOME/.bashrc"
if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
    TARGET_FILE="$HOME/.zshrc"
fi

LOAD_CMD="[ -f \"$SLI_ROOT/core/wsl/sli-wsl.sh\" ] && source \"$SLI_ROOT/core/wsl/sli-wsl.sh\""

if grep -q "sli-wsl.sh" "$TARGET_FILE" 2>/dev/null; then
    echo "ℹ 已在 $TARGET_FILE 中找到 S-li 配置，無需重複加入。"
else
    echo "" >> "$TARGET_FILE"
    echo "# S-li Terminal Prompt Engine" >> "$TARGET_FILE"
    echo "$LOAD_CMD" >> "$TARGET_FILE"
    echo "✓ 已成功將 S-li 寫入 $TARGET_FILE"
fi

echo ""
echo "🎉 安裝完成！請執行 'source $TARGET_FILE' 即可立即看見全新終端效果！"
echo ""
