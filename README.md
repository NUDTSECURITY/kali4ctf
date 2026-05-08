# Kali MCP Docker

[English](#english) | [中文](#中文)

---

## 中文

### 简介

基于 Kali Linux 的 Docker 镜像，集成了 MCP 服务器和 60+ 安全工具。用于 CTF 比赛、渗透测试和安全研究。


### 工具清单

| 分类 | 工具 |
|------|------|
| 信息收集 | nmap, amass, subfinder, whatweb, httpx-toolkit, naabu, dnsx |
| Web 渗透 | gobuster, dirsearch, nikto, sqlmap, ffuf, wpscan |
| 漏洞利用 | metasploit-framework, hydra, crackmapexec, impacket-scripts |
| Pwn / 逆向 | gdb-multiarch, pwndbg, checksec, radare2, pwntools, ROPgadget, one-gadget |
| 取证 | binwalk, foremost, steghide, zsteg, exiftool, volatility3, yara, scalpel, sleuthkit, tesseract-ocr |
| 密码学 | hashcat, john, RsaCtfTool, z3-solver, pycryptodome, mythril |
| 区块链 | forge, cast, anvil (Foundry), web3, slither-analyzer, solc-select |
| AI 安全 | adversarial-robustness-toolbox, textattack, openai, litellm, torch |
| 网络 | ncat, proxychains4, tshark, tcpdump, sslscan |
| 编程环境 | Python 3, Go, Ruby, PHP, Node.js 20, C/C++ |

### 快速上手

```bash
git clone https://github.com/NUDTSECURITY/kali4ctf.git
cd kali4ctf

# 构建（首次约 43GB，建议挂代理）
docker build -t kali-mcp:latest .

# 启动
docker compose up -d

# 验证
curl http://localhost:5000/health

# 进入容器
docker exec -it kali-mcp bash
```

### 配置 Claude Desktop

将以下内容添加到 Claude Desktop 的 MCP 配置文件：

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

### HTTP API

不走 MCP 也可以直接调 REST 接口：

```bash
# 通用命令
curl -X POST http://localhost:5000/api/command \
  -H "Content-Type: application/json" \
  -d '{"command": "nmap -sV 127.0.0.1"}'

# nmap 专用
curl -X POST http://localhost:5000/api/tools/nmap \
  -H "Content-Type: application/json" \
  -d '{"target": "192.168.1.1", "scan_type": "-sV", "ports": "22,80,443"}'
```

### 镜像源

默认使用清华源。如需切换：

```bash
docker build --build-arg KALI_MIRROR=http://http.kali.org/kali -t kali-mcp:latest .
```

### 文件结构

```
kali4ctf/
├── .claude/
│   ├── hooks/
│   │   └── ensure-kali.sh  # SessionStart hook，自动启动/恢复容器
│   └── settings.json       # Claude Code hook 配置
├── Dockerfile
├── docker-compose.yml
├── entrypoint.sh
├── kali_server.py          # Flask API 服务端
├── src/my_server/
│   ├── __init__.py
│   └── mcp_server.py       # MCP 客户端
├── LICENSE
└── README.md
```

### Claude Code Hook

项目内置了 `SessionStart` hook（`.claude/hooks/ensure-kali.sh`），每次启动 Claude Code 会话时自动：

1. 检查 `localhost:5000/health` 是否可达
2. 如果容器不存在，自动 `docker run` 启动
3. 如果容器已暂停，自动 `docker unpause`
4. 如果容器异常（exited/dead），自动删除并重建
5. 等待最多 30 秒直到健康检查通过

使用 Claude Code 打开此项目目录即可自动生效，无需手动 `docker compose up`。

### FAQ

**Q: 构建太慢**
A: 首次构建要下载约 43GB，建议 `--network=host` + 代理。后续有 Docker 缓存会快很多。

**Q: Mac M1 能用吗**
A: 目前是 x86_64 镜像，ARM 需要 `--platform linux/amd64` 走模拟，速度较慢。

**Q: 安全性**
A: 镜像包含大量攻击工具，不要暴露到公网，仅限本地或内网使用。

---

<a id="english"></a>

## English

### What is this

A Docker image based on Kali Linux with MCP server integration and 60+ security tools. For CTF, penetration testing, and security research.

Built on [MCP-Kali-Server](https://github.com/Wh0am123/MCP-Kali-Server).

### Tools

| Category | Tools |
|----------|-------|
| Recon | nmap, amass, subfinder, whatweb, httpx-toolkit, naabu, dnsx |
| Web | gobuster, dirsearch, nikto, sqlmap, ffuf, wpscan |
| Exploitation | metasploit-framework, hydra, crackmapexec, impacket-scripts |
| Pwn/RE | gdb-multiarch, pwndbg, checksec, radare2, pwntools, ROPgadget, one-gadget |
| Forensics | binwalk, foremost, steghide, zsteg, exiftool, volatility3, yara, scalpel, sleuthkit, tesseract-ocr |
| Crypto | hashcat, john, RsaCtfTool, z3-solver, pycryptodome, mythril |
| Blockchain | forge, cast, anvil (Foundry), web3, slither-analyzer, solc-select |
| AI Security | adversarial-robustness-toolbox, textattack, openai, litellm, torch |
| Network | ncat, proxychains4, tshark, tcpdump, sslscan |
| Languages | Python 3, Go, Ruby, PHP, Node.js 20, C/C++ |

### Quick Start

```bash
git clone https://github.com/NUDTSECURITY/kali4ctf.git
cd kali4ctf

# Build (~43GB first time, use a proxy)
docker build -t kali-mcp:latest .

# Start
docker compose up -d

# Verify
curl http://localhost:5000/health

# Shell in
docker exec -it kali-mcp bash
```

### Claude Desktop Config

Add to your Claude Desktop MCP config:

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

### HTTP API

Use the REST API directly without MCP:

```bash
# Generic command
curl -X POST http://localhost:5000/api/command \
  -H "Content-Type: application/json" \
  -d '{"command": "nmap -sV 127.0.0.1"}'

# nmap endpoint
curl -X POST http://localhost:5000/api/tools/nmap \
  -H "Content-Type: application/json" \
  -d '{"target": "192.168.1.1", "scan_type": "-sV", "ports": "22,80,443"}'
```

### Mirror

Default mirror is Tsinghua. To switch:

```bash
docker build --build-arg KALI_MIRROR=http://http.kali.org/kali -t kali-mcp:latest .
```

### File Structure

```
kali4ctf/
├── .claude/
│   ├── hooks/
│   │   └── ensure-kali.sh  # SessionStart hook, auto-start/resume container
│   └── settings.json       # Claude Code hook config
├── Dockerfile
├── docker-compose.yml
├── entrypoint.sh
├── kali_server.py          # Flask API server
├── src/my_server/
│   ├── __init__.py
│   └── mcp_server.py       # MCP client
├── LICENSE
└── README.md
```

### Claude Code Hook

The project includes a `SessionStart` hook (`.claude/hooks/ensure-kali.sh`) that automatically:

1. Checks if `localhost:5000/health` is reachable
2. If no container exists, runs `docker run` to start it
3. If container is paused, runs `docker unpause`
4. If container is in a bad state (exited/dead), removes and recreates it
5. Waits up to 30 seconds for health check to pass

Simply open this project directory in Claude Code — no need to manually run `docker compose up`.

### FAQ

**Q: Build is too slow**
A: First build downloads ~43GB. Use `--network=host` and a proxy. Subsequent builds benefit from Docker layer caching.

**Q: Does this work on Mac M1?**
A: This is an x86_64 image. ARM requires `--platform linux/amd64` emulation which is slow.

**Q: Is it safe?**
A: The image contains offensive security tools. Do not expose to the public internet.

---

## Credits

- [MCP-Kali-Server](https://github.com/Wh0am123/MCP-Kali-Server) — MCP server
- [Kali Linux](https://www.kali.org/) — Base image
- [Foundry](https://book.getfoundry.sh/) — Blockchain toolkit
- [pwndbg](https://github.com/pwndbg/pwndbg) — GDB plugin

## License

MIT. See [LICENSE](LICENSE).
