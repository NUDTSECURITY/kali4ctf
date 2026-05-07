# Kali MCP Docker 🐉

> 一个把 Kali Linux + MCP 服务器 + 60+ 安全工具打包到 Docker 里的全能 CTF 战舰。
>
> An all-in-one Kali Linux Docker image with MCP server integration. Your AI-powered CTF battleship.

[English](#english) | [中文](#中文)

---

## 中文

### 这是什么？

一个 Docker 镜像，开箱即用，包含：

- **Kali Linux** 最新滚动发行版
- **60+ 安全工具** 从 nmap 到 metasploit 到 foundry，全家桶
- **MCP 服务器** 让 Claude 等 AI 助手直接调用渗透工具
- **开箱即用** 不用再折腾安装依赖、解决冲突、等编译

一句话：`docker compose up -d` 然后开干 🔥

### 工具清单

| 分类 | 工具 |
|------|------|
| **信息收集** | nmap, amass, subfinder, whatweb, httpx-toolkit, naabu, dnsx |
| **Web 渗透** | gobuster, dirsearch, nikto, sqlmap, ffuf, wpscan |
| **漏洞利用** | metasploit-framework, hydra, crackmapexec, impacket-scripts |
| **Pwn / 逆向** | gdb-multiarch, pwndbg, checksec, radare2, pwntools, ROPgadget, one-gadget |
| **取证** | binwalk, foremost, steghide, zsteg, exiftool, volatility3, yara, scalpel, sleuthkit, tesseract-ocr |
| **密码学** | hashcat, john, RsaCtfTool, z3-solver, pycryptodome, mythril |
| **区块链** | forge, cast, anvil (Foundry), web3, slither-analyzer, solc-select |
| **AI 安全** | adversarial-robustness-toolbox, textattack, openai, litellm, torch |
| **网络** | ncat, proxychains4, tshark, tcpdump, sslscan |
| **编程环境** | Python 3, Go, Ruby, PHP, Node.js 20, C/C++ |

### 快速上手

```bash
# 1. 克隆仓库
git clone https://github.com/yourname/kali-mcp-docker.git
cd kali-mcp-docker

# 2. 构建镜像（首次需要一些时间，大概 ~43GB，去泡杯咖啡 ☕）
docker build -t kali-mcp:latest .

# 3. 启动容器
docker compose up -d

# 4. 验证 MCP 服务是否正常
curl http://localhost:5000/health

# 5. 进入容器操作
docker exec -it kali-mcp bash
```

### 配置 Claude Desktop

把下面这段加到 Claude Desktop 的 MCP 配置文件里：

- Linux: `~/.config/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "kali": {
      "command": "python3",
      "args": [
        "/path/to/src/my_server/mcp_server.py",
        "--server",
        "http://localhost:5000/"
      ]
    }
  }
}
```

配好之后就可以在 Claude 里直接说 "帮我用 nmap 扫一下 192.168.1.0/24" 了 🎯

### 也能当 HTTP API 用

不想接 MCP？直接 REST 调用也行：

```bash
# 通用命令执行
curl -X POST http://localhost:5000/api/command \
  -H "Content-Type: application/json" \
  -d '{"command": "nmap -sV 127.0.0.1"}'

# nmap 专用接口
curl -X POST http://localhost:5000/api/tools/nmap \
  -H "Content-Type: application/json" \
  -d '{"target": "192.168.1.1", "scan_type": "-sV", "ports": "22,80,443"}'
```

### 国内镜像加速

默认使用清华镜像源加速构建。想换成官方源：

```bash
docker build --build-arg KALI_MIRROR=http://http.kali.org/kali -t kali-mcp:latest .
```

### 文件结构

```
kali-mcp-docker/
├── Dockerfile              # 镜像定义，所有工具的安装逻辑
├── docker-compose.yml      # Compose 配置
├── entrypoint.sh           # 容器启动脚本
├── kali_server.py          # Flask API 服务端
├── src/my_server/
│   ├── __init__.py
│   └── mcp_server.py       # MCP 客户端
├── LICENSE                 # MIT
└── README.md               # 你正在看的这个文件 👀
```

### 常见问题

**Q: 构建好慢啊**
A: 首次构建要下载 ~43GB 的工具链和依赖，建议用 `--network=host` 并且挂代理。后续构建有 Docker 缓存就快了。

**Q: 能跑在 Mac M1 上吗**
A: 这个镜像基于 x86_64，ARM 需要加 `--platform linux/amd64` 走模拟，会比较慢。PR welcome 加 ARM 支持 🙏

**Q: 容器安全吗**
A: 容器里工具齐全，**不要把它暴露到公网**。仅在本地或内网使用。

---

<a id="english"></a>

## English

### What is this?

A Docker image that packs Kali Linux + MCP server + 60+ security tools into one ready-to-go container. No dependency hell, no compile errors, no wasted weekends.

Just `docker compose up -d` and start pwning 🔥

### Tools Included

| Category | Tools |
|----------|-------|
| **Recon** | nmap, amass, subfinder, whatweb, httpx-toolkit, naabu, dnsx |
| **Web** | gobuster, dirsearch, nikto, sqlmap, ffuf, wpscan |
| **Exploitation** | metasploit-framework, hydra, crackmapexec, impacket-scripts |
| **Pwn/RE** | gdb-multiarch, pwndbg, checksec, radare2, pwntools, ROPgadget, one-gadget |
| **Forensics** | binwalk, foremost, steghide, zsteg, exiftool, volatility3, yara, scalpel, sleuthkit, tesseract-ocr |
| **Crypto** | hashcat, john, RsaCtfTool, z3-solver, pycryptodome, mythril |
| **Blockchain** | forge, cast, anvil (Foundry), web3, slither-analyzer, solc-select |
| **AI Security** | adversarial-robustness-toolbox, textattack, openai, litellm, torch |
| **Network** | ncat, proxychains4, tshark, tcpdump, sslscan |
| **Languages** | Python 3, Go, Ruby, PHP, Node.js 20, C/C++ |

### Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/yourname/kali-mcp-docker.git
cd kali-mcp-docker

# 2. Build the image (first time takes a while, ~43GB, grab a coffee ☕)
docker build -t kali-mcp:latest .

# 3. Start the container
docker compose up -d

# 4. Verify MCP server is healthy
curl http://localhost:5000/health

# 5. Shell into the container
docker exec -it kali-mcp bash
```

### Claude Desktop Integration

Add this to your Claude Desktop MCP config:

- Linux: `~/.config/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "kali": {
      "command": "python3",
      "args": [
        "/path/to/src/my_server/mcp_server.py",
        "--server",
        "http://localhost:5000/"
      ]
    }
  }
}
```

Now you can literally tell Claude "run an nmap scan on 192.168.1.0/24" and it will do it 🎯

### HTTP API (No MCP needed)

Don't want MCP? Use the REST API directly:

```bash
# Generic command execution
curl -X POST http://localhost:5000/api/command \
  -H "Content-Type: application/json" \
  -d '{"command": "nmap -sV 127.0.0.1"}'

# nmap-specific endpoint
curl -X POST http://localhost:5000/api/tools/nmap \
  -H "Content-Type: application/json" \
  -d '{"target": "192.168.1.1", "scan_type": "-sV", "ports": "22,80,443"}'
```

### Mirror Configuration

Default mirror is Tsinghua (China). To use the official Kali mirror:

```bash
docker build --build-arg KALI_MIRROR=http://http.kali.org/kali -t kali-mcp:latest .
```

### File Structure

```
kali-mcp-docker/
├── Dockerfile              # Image definition, all tool installation
├── docker-compose.yml      # Compose configuration
├── entrypoint.sh           # Container entrypoint
├── kali_server.py          # Flask API server
├── src/my_server/
│   ├── __init__.py
│   └── mcp_server.py       # MCP client
├── LICENSE                 # MIT
└── README.md               # You are here 👀
```

### FAQ

**Q: The build is so slow**
A: First build downloads ~43GB of tools and dependencies. Use `--network=host` and a proxy. Subsequent builds are fast thanks to Docker layer caching.

**Q: Can I run this on Mac M1?**
A: This image is x86_64. Add `--platform linux/amd64` for emulation (slow). PRs welcome for ARM support 🙏

**Q: Is this safe to run?**
A: The container is full of offensive security tools. **Do not expose it to the public internet.** Use locally or on a trusted network only.

---

## Credits 🙏

- [MCP-Kali-Server](https://github.com/Wh0am123/MCP-Kali-Server) by Yousof Nahya — MCP server foundation
- [Kali Linux](https://www.kali.org/) — Base image and tools
- [Foundry](https://book.getfoundry.sh/) — Blockchain toolkit
- [pwndbg](https://github.com/pwndbg/pwndbg) — GDB enhanced plugin

## License

MIT. See [LICENSE](LICENSE).
