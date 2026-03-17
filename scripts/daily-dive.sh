#!/bin/bash
# Daily Deep-Dive into Awesome Lists
# Usage: bash scripts/daily-dive.sh [category]
# Example: bash scripts/daily-dive.sh awesome-llm

set -e

DATE=$(date +%Y-%m-%d)
OUTPUT="discovered/${DATE}.md"
mkdir -p discovered

echo "# 🔍 Deep Dive — ${DATE}" > "$OUTPUT"
echo "" >> "$OUTPUT"

# 如果指定了分类，只深挖该分类
TARGET="${1:-}"

if [ -z "$TARGET" ]; then
    # 轮询：从 categories/README.md 取第一个未处理的
    TARGET=$(grep '^\- \[ \]' categories/README.md | head -1 | sed 's/.*\(awesome-[^]]*\).*/\1/')
fi

if [ -z "$TARGET" ]; then
    echo "✅ All categories processed. Resetting..."
    sed -i 's/^\- \[x\]/- [ ]/g' categories/README.md
    exit 0
fi

echo "🎯 Today's target: ${TARGET}"
echo "## Source: ${TARGET}" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# 获取该 awesome 列表的 README
REPO_URL=""
case "$TARGET" in
    awesome-llm) REPO_URL="https://github.com/Hannibal046/Awesome-LLM" ;;
    awesome-ai-agents) REPO_URL="https://github.com/e2b-dev/awesome-ai-agents" ;;
    awesome-python) REPO_URL="https://github.com/vinta/awesome-python" ;;
    awesome-machine-learning) REPO_URL="https://github.com/josephmisiti/awesome-machine-learning" ;;
    awesome-cli-apps) REPO_URL="https://github.com/agarrharr/awesome-cli-apps" ;;
    *) REPO_URL="https://github.com/${TARGET}" ;;
esac

echo "📥 Fetching from: ${REPO_URL}"

# 提取前500行相关段落
curl -sL "${REPO_URL}/raw/main/README.md" 2>/dev/null | head -500 > /tmp/dive-content.md

# 统计
TOTAL_LINKS=$(grep -c 'http' /tmp/dive-content.md || echo 0)
echo "📊 Found ${TOTAL_LINKS} links in ${TARGET}"
echo "- **Source**: ${REPO_URL}" >> "$OUTPUT"
echo "- **Links found**: ${TOTAL_LINKS}" >> "$OUTPUT"
echo "- **Status**: 待人工/AI 深挖筛选" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# 提取 AI/Agent 相关条目
echo "### Relevant entries:" >> "$OUTPUT"
grep -iE '(agent|llm|gpt|claude|prompt|memory|evolution|self-improve|reasoning|planning|tool|sdk|framework|automation)' /tmp/dive-content.md | head -20 >> "$OUTPUT" 2>/dev/null || echo "No matches" >> "$OUTPUT"

echo "" >> "$OUTPUT"
echo "✅ Deep-dive results written to ${OUTPUT}"
echo "📋 Next: Review entries, add useful ones to README.md"
