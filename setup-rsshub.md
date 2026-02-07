# RSSHub 自建部署指南

## 简介

RSSHub 是一个开源的 RSS 生成器，可以为没有 RSS 的网站生成 RSS 订阅源。自建 RSSHub 可以解决：
- 公共服务 403 限流问题
- 国内财经媒体（财新、财联社、雪球等）访问受限
- 提高抓取稳定性和速度

---

## 方案一：Docker 部署（推荐）

### 1. 环境准备

确保已安装 Docker：
```bash
# macOS
brew install docker

# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io

# CentOS
sudo yum install docker
```

### 2. 部署 RSSHub

#### 方式 A：简单启动（最快）
```bash
docker run -d --name rsshub -p 1200:1200 diygod/rsshub
```

#### 方式 B：使用 Docker Compose（推荐）

创建 `docker-compose.yml`：
```yaml
version: '3'

services:
  rsshub:
    image: diygod/rsshub:latest
    container_name: rsshub
    ports:
      - "1200:1200"
    environment:
      # 缓存配置（可选）
      CACHE_TYPE: redis
      REDIS_URL: redis://redis:6379/
      # 访问控制（可选）
      # ACCESS_KEY: your_access_key
    depends_on:
      - redis
    restart: always

  redis:
    image: redis:alpine
    container_name: rsshub-redis
    volumes:
      - redis-data:/data
    restart: always

volumes:
  redis-data:
```

启动服务：
```bash
docker-compose up -d
```

### 3. 验证部署

```bash
# 检查容器运行状态
docker ps

# 测试 RSSHub 服务
curl http://localhost:1200

# 测试国内财经源（替换之前 403 的源）
curl http://localhost:1200/caixin/latest
curl http://localhost:1200/cls/telegraph
curl http://localhost:1200/xueqiu/hots
```

---

## 方案二：服务器部署（生产环境）

如果你在云服务器（阿里云、腾讯云等）上部署：

### 1. 安装 Docker
```bash
curl -fsSL https://get.docker.com | sh
sudo systemctl enable docker
sudo systemctl start docker
```

### 2. 部署 RSSHub
```bash
# 创建目录
mkdir -p ~/rsshub && cd ~/rsshub

# 下载配置文件
curl -o docker-compose.yml https://raw.githubusercontent.com/DIYgod/RSSHub/master/docker-compose.yml

# 启动
docker-compose up -d
```

### 3. 配置 Nginx 反向代理（可选）

如果你有域名，可以配置 Nginx：
```nginx
server {
    listen 80;
    server_name rsshub.yourdomain.com;
    
    location / {
        proxy_pass http://localhost:1200;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## 方案三：使用 RSSHub 镜像站

如果你不想自建，可以使用以下公共镜像（稳定性不保证）：

| 镜像地址 | 说明 |
|---------|------|
| https://rsshub.rssforever.com | 国内镜像 |
| https://hub.slarker.me | 国内镜像 |
| https://rsshub.pseudoyu.com | 个人镜像 |

使用方式：将 `https://rsshub.app` 替换为镜像地址

---

## 配置 TrendRadar 使用自建 RSSHub

### 1. 修改 config/config.yaml

将之前失败的 RSS 源从 `rsshub.app` 改为你的 RSSHub 地址：

```yaml
rss:
  feeds:
    # 之前 403 的源，改为自建 RSSHub
    - id: "caixin"
      name: "财新"
      url: "http://localhost:1200/caixin/latest"  # 改为本地 RSSHub
      enabled: true
      max_age_days: 1

    - id: "cls-telegraph"
      name: "财联社电报"
      url: "http://localhost:1200/cls/telegraph"
      enabled: true
      max_age_days: 1

    - id: "yicai"
      name: "第一财经"
      url: "http://localhost:1200/yicai/brief"
      enabled: true
      max_age_days: 1

    - id: "xueqiu-hot"
      name: "雪球热帖"
      url: "http://localhost:1200/xueqiu/hots"
      enabled: true
      max_age_days: 1
```

### 2. 重启 TrendRadar

```bash
cd /Users/admin/workspace/TrendRadar
source .venv/bin/activate
python -m trendradar
```

---

## RSSHub 常用路由参考

以下是 TrendRadar 中常用的 RSSHub 路由：

| 媒体 | RSSHub 路由 | 说明 |
|------|------------|------|
| 财新 | `/caixin/latest` | 最新文章 |
| 财联社电报 | `/cls/telegraph` | 实时快讯 |
| 财联社深度 | `/cls/depth` | 深度报道 |
| 第一财经 | `/yicai/brief` |  Brief |
| 雪球热帖 | `/xueqiu/hots` | 热门帖子 |
| 新浪财经 | `/sina/finance` | 财经新闻 |
| 华尔街日报 | `/wsj/zh-hans` | 中文 |
| Hacker News | `/hackernews` | 热门 |
| GitHub Trending | `/github/trending/daily/python` | Python |
| 36氪 | `/36kr/newsflashes` | 快讯 |

完整路由列表：https://docs.rsshub.app

---

## 故障排查

### 1. RSSHub 启动失败
```bash
# 查看日志
docker logs rsshub

# 重启服务
docker restart rsshub
```

### 2. 国内源仍然 403
- 检查 RSSHub 是否使用了代理
- 考虑在服务器上部署（而非本地）
- 使用国内的 RSSHub 镜像

### 3. 内存占用过高
```bash
# 限制 RSSHub 内存使用
docker run -d --name rsshub -p 1200:1200 -m 512m diygod/rsshub
```

---

## 进阶配置

### 启用缓存（提高性能）
```bash
docker run -d \
  --name rsshub \
  -p 1200:1200 \
  -e CACHE_TYPE=memory \
  -e CACHE_EXPIRE=300 \
  diygod/rsshub
```

### 配置访问控制
```bash
docker run -d \
  --name rsshub \
  -p 1200:1200 \
  -e ACCESS_KEY=your_secret_key \
  diygod/rsshub
```
访问时需要加 `?key=your_secret_key`

---

## 总结

自建 RSSHub 后可以获取：
- ✅ 财新、财联社、第一财经等国内财经媒体
- ✅ 雪球、东方财富等投资社区
- ✅ 更稳定的 RSS 服务（不受公共服务限流影响）
- ✅ 更快的响应速度（本地/内网访问）

推荐在生产环境使用服务器部署，开发测试可以使用本地 Docker。
