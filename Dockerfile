FROM docker.io/cloudflare/sandbox:0.7.20

# Install Node.js 24 & upgrade npm to v12 without hardcoded URLs
RUN npm install -g n npm@12.2.3 \
    && n 24.22.1 \
    && hash -r \
    && node --version \
    && npm --version

# Clean any pre-installed openclaw binary and install 2026.11.3
ARG CACHE_BUST=2026-11-19-moltbot1sandbox-v4
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
