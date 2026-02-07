#!/bin/bash

echo "=== RSSHub 启动脚本 ==="
echo ""

# 检查 colima 状态
echo "1. 检查 Colima 状态..."
if ! colima status > /dev/null 2>&1; then
    echo "   Colima 未运行，正在启动..."
    echo "   首次启动需要下载虚拟机镜像，请耐心等待 2-3 分钟..."
    colima start
else
    echo "   Colima 运行中 ✓"
fi

# 检查 RSSHub 容器
echo ""
echo "2. 检查 RSSHub 容器..."
if docker ps | grep -q rsshub; then
    echo "   RSSHub 已在运行 ✓"
    echo "   访问地址: http://localhost:1200"
else
    echo "   启动 RSSHub..."
    docker run -d --name rsshub -p 1200:1200 --restart always diygod/rsshub
    echo "   RSSHub 启动成功 ✓"
    echo "   访问地址: http://localhost:1200"
fi

echo ""
echo "3. 测试 RSSHub 服务..."
sleep 3
if curl -s http://localhost:1200 > /dev/null; then
    echo "   RSSHub 服务正常 ✓"
    echo ""
    echo "=== 测试国内财经源 ==="
    echo "测试财新:"
    curl -s http://localhost:1200/caixin/latest | head -20
else
    echo "   RSSHub 服务未响应，请稍后再试"
fi

echo ""
echo "=== 使用说明 ==="
echo "RSSHub 已部署完成！"
echo ""
echo "1. 访问 RSSHub 首页:"
echo "   http://localhost:1200"
echo ""
echo "2. 常用财经源地址:"
echo "   财新:        http://localhost:1200/caixin/latest"
echo "   财联社电报:  http://localhost:1200/cls/telegraph"
echo "   第一财经:    http://localhost:1200/yicai/brief"
echo "   雪球热帖:    http://localhost:1200/xueqiu/hots"
echo ""
echo "3. 修改 TrendRadar 配置:"
echo "   将 config/config.yaml 中的 rsshub.app 替换为 localhost:1200"
echo ""
echo "4. 常用命令:"
echo "   查看日志:    docker logs rsshub"
echo "   重启服务:    docker restart rsshub"
echo "   停止服务:    docker stop rsshub"
echo "   删除容器:    docker rm -f rsshub"
