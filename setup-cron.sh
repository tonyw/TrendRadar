#!/bin/bash

# 设置 TrendRadar 每2小时运行一次的定时任务

PROJECT_DIR="/Users/admin/workspace/TrendRadar"
LOG_FILE="$PROJECT_DIR/logs/cron.log"

# 创建日志目录
mkdir -p "$PROJECT_DIR/logs"

# 创建临时脚本
TEMP_SCRIPT=$(mktemp)
cat > "$TEMP_SCRIPT" << 'EOF'
#!/bin/bash
cd /Users/admin/workspace/TrendRadar
source .venv/bin/activate
python -m trendradar >> logs/cron.log 2>&1
EOF

chmod +x "$TEMP_SCRIPT"

# 显示当前 cron 任务
echo "当前 cron 任务:"
crontab -l 2>/dev/null || echo "(无)"

echo ""
echo "添加 TrendRadar 定时任务..."

# 添加到 crontab
(crontab -l 2>/dev/null; echo "0 */2 * * * $TEMP_SCRIPT") | crontab -

echo "✅ 定时任务已添加！"
echo ""
echo "新的 cron 任务:"
crontab -l | grep -E "trendradar|TEMP_SCRIPT"

echo ""
echo "📋 常用命令:"
echo "  查看所有任务: crontab -l"
echo "  编辑任务:     crontab -e"
echo "  删除所有任务: crontab -r"
echo "  查看日志:     tail -f $LOG_FILE"
