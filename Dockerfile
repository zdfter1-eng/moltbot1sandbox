FROM docker.io/cloudflare/sandbox:0.7.20

# 1. Install n and switch Node to 24.22.1 first
RUN npm install -g n \
    && n 24.22.1 \
    && hash -r \
    && node --version

# 2. Now upgrade npm to v12 (on Node 24)
RUN npm install -g npm@12.2.3 \
    && npm --version

# 3. Clean any pre-installed openclaw binary and install 2026.11.3
ARG CACHE_BUST=2026-11-19-moltbot1sandbox-v5
RUN npm uninstall -g openclaw || true \
    && rm -f /usr/bin/openclaw /usr/local/bin/openclaw \
    && npm install -g openclaw@2026.11.3 \
    && openclaw --version

# Use /home/openclaw as the home directory instead of /root.
ENV HOME=/home/openclaw
RUN mkdir -p /home/openclaw/.openclaw \
    && mkdir -p /home/openclaw/clawd \
    && mkdir -p /home/openclaw/clawd/skills \
    && ln -s /home/openclaw/.openclaw /root/.openclaw \
    && ln -s /home/openclaw/clawd /root/clawd

# Copy startup script
COPY start-openclaw.sh /usr/local/bin/start-openclaw.sh
RUN chmod +x /usr/local/bin/start-openclaw.sh

# Copy custom skills
COPY skills/ /home/openclaw/clawd/skills/

# Ensure all files are readable for mksquashfs
RUN chmod -R a+rX /home/openclaw

WORKDIR /home/openclaw/clawd
EXPOSE 18789
