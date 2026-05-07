FROM kalilinux/kali-rolling

ARG KALI_MIRROR=https://mirrors.tuna.tsinghua.edu.cn/kali
ENV DEBIAN_FRONTEND=noninteractive

# ============================================================
# Stage 1: Base Environment
# ============================================================

# Initialize certificates + switch to mirror (optional, default is official)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates; \
    rm -rf /var/lib/apt/lists/*

# Use Tsinghua mirror for faster builds in China. Remove or change for other regions.
RUN set -eux; \
    printf 'deb %s kali-rolling main contrib non-free non-free-firmware\n' "$KALI_MIRROR" > /etc/apt/sources.list; \
    printf 'deb-src %s kali-rolling main contrib non-free non-free-firmware\n' "$KALI_MIRROR" >> /etc/apt/sources.list

RUN apt-get update && apt-get -y install \
    wget curl ca-certificates git \
    python3 python3-pip python3-venv \
    unzip jq iputils-ping dnsutils net-tools iproute2 \
    default-jre-headless \
    socat \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# ============================================================
# Stage 2: Penetration Testing Tools (Web / Network / Exploitation)
# ============================================================

RUN apt-get update && apt-get install -y \
    nmap gobuster dirsearch whatweb amass subfinder \
    httpx-toolkit naabu dnsx sslscan \
    sqlmap seclists nuclei nikto ffuf wpscan \
    impacket-scripts crackmapexec bloodhound \
    hydra john hashcat peass \
    ncat netcat-openbsd proxychains4 tmux screen \
    metasploit-framework exploitdb \
    mcp-kali-server \
    && rm -rf /var/lib/apt/lists/*

# ============================================================
# Stage 3: Pwn / Reverse Engineering
# ============================================================

RUN apt-get update && apt-get install -y \
    gdb gdbserver gdb-multiarch \
    checksec \
    radare2 \
    binwalk foremost steghide \
    libc6-dbg \
    && rm -rf /var/lib/apt/lists/*

# pwndbg (GDB enhanced plugin)
RUN git clone https://github.com/pwndbg/pwndbg /opt/pwndbg \
    && cd /opt/pwndbg && ./setup.sh \
    && rm -rf /opt/pwndbg/.git \
    || echo "[!] pwndbg install failed, skipping"

# ============================================================
# Stage 4: MISC / AWD / Programming Languages
# ============================================================

RUN apt-get update && apt-get install -y \
    libimage-exiftool-perl \
    qrencode zbar-tools \
    pngcheck \
    hexedit xxd \
    tshark tcpdump \
    ffmpeg sox \
    gcc g++ make cmake \
    golang \
    php php-cli \
    ruby ruby-dev \
    openssh-client \
    strace ltrace \
    patchelf \
    python3-matplotlib \
    && rm -rf /var/lib/apt/lists/*

# zsteg (Ruby gem for steganography)
RUN gem install zsteg

# ============================================================
# Stage 5: Forensics
# ============================================================

RUN apt-get update && apt-get install -y \
    tesseract-ocr tesseract-ocr-eng tesseract-ocr-chi-sim \
    yara \
    md5deep \
    scalpel \
    bulk-extractor \
    dc3dd \
    sleuthkit \
    clamav clamav-daemon \
    && rm -rf /var/lib/apt/lists/*

# Binwalk extraction dependencies
RUN apt-get update && apt-get install -y \
    mtd-utils gzip bzip2 tar arj lhasa \
    p7zip p7zip-full cabextract \
    cramfsswap squashfs-tools \
    lzop srecord \
    && rm -rf /var/lib/apt/lists/*

# Update ClamAV virus database
RUN freshclam || true

# ============================================================
# Stage 6: Blockchain (Foundry)
# ============================================================

RUN curl -L https://foundry.paradigm.xyz | bash \
    && /root/.foundry/bin/foundryup \
    && ln -sf /root/.foundry/bin/forge /usr/local/bin/forge \
    && ln -sf /root/.foundry/bin/cast /usr/local/bin/cast \
    && ln -sf /root/.foundry/bin/anvil /usr/local/bin/anvil \
    && ln -sf /root/.foundry/bin/chisel /usr/local/bin/chisel \
    || echo "[!] Foundry install failed, skipping"

# ============================================================
# Stage 7: Python Security Libraries
# ============================================================

# Pwn / Crypto
RUN pip3 install --break-system-packages \
    bloodhound pwntools ropper ROPgadget one-gadget \
    z3-solver gmpy2 pycryptodome pycryptodomex tqdm

# Blockchain / Smart Contract
RUN pip3 install --break-system-packages \
    web3 py-solc-x eth_abi slither-analyzer

# Network / Interaction
RUN pip3 install --break-system-packages \
    pyshark pwncat pexpect

# AI / LLM
RUN pip3 install --break-system-packages --ignore-installed \
    openai anthropic litellm transformers tokenizers

# PyTorch (CPU-only to reduce image size)
RUN pip3 install --break-system-packages --ignore-installed torch \
    --index-url https://download.pytorch.org/whl/cpu

# Crypto / Forensics / Blockchain
RUN pip3 install --break-system-packages --ignore-installed \
    volatility3 mythril solc-select factordb-pycli

# AI Adversarial
RUN pip3 install --break-system-packages --ignore-installed \
    adversarial-robustness-toolbox
RUN pip3 install --break-system-packages --ignore-installed \
    textattack
RUN pip3 install --break-system-packages --ignore-installed garak \
    || echo "[!] garak install failed (cohere unavailable on this Python version), skipping"

# RsaCtfTool (automated RSA attacks)
RUN git clone https://github.com/Ganapati/RsaCtfTool.git /opt/RsaCtfTool \
    && cd /opt/RsaCtfTool \
    && pip3 install --break-system-packages -r requirements.txt || true \
    && ln -sf /opt/RsaCtfTool/RsaCtfTool.py /usr/local/bin/rsactftool \
    || echo "[!] RsaCtfTool install failed, skipping"

# ============================================================
# Stage 8: Resources & Cleanup
# ============================================================

# Update nuclei templates
RUN nuclei -ut || echo "[!] nuclei template update failed, skipping"

# Decompress rockyou wordlist
RUN gunzip -f /usr/share/wordlists/rockyou.txt.gz 2>/dev/null || true

# Cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    touch /root/THIS_IS_DOCKER_CONTAINER_NOT_TARGET_MACHINE.txt

# Patch mcp-kali-server: CommandExecutor must accept list commands (nmap fix)
RUN python3 <<'PYEOF'
import pathlib
p = pathlib.Path("/usr/share/mcp-kali-server/server.py")
c = p.read_text()
old = (
    "        if not isinstance(self.command, str):\n"
    '            raise ValueError(f"CommandExecutor expects a string, but got {type(self.command).__name__}")\n'
    "\n"
    "        cmd_args = shlex.split(self.command)"
)
new = (
    "        if isinstance(self.command, list):\n"
    "            cmd_args = self.command\n"
    "        else:\n"
    "            cmd_args = shlex.split(self.command)"
)
p.write_text(c.replace(old, new))
PYEOF

# ============================================================
# Stage 9: Entrypoint
# ============================================================

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh && dos2unix /usr/local/bin/entrypoint.sh

EXPOSE 5000
WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
