version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=${domain}
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - GENERIC_TIMEZONE=${timezone}
      - TZ=${timezone}
      - N8N_SECURE_COOKIE=false
      - WEBHOOK_URL=https://${domain}/
      - N8N_BLOCK_ENV_ACCESS_IN_NODE=false
      - N8N_GIT_NODE_DISABLE_BARE_REPOS=true
      - N8N_COMMUNITY_NODES_ENABLED=false
      - N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
      
      # User Management
      - N8N_USER_MANAGEMENT_DISABLED=false
    volumes:
      - n8n_data:/home/node/.n8n
      - ./local-files:/files
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost:5678/healthz"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - n8n-network

  cloudflare-tunnel:
    image: cloudflare/cloudflared:latest
    container_name: cloudflare-tunnel
    restart: unless-stopped
    command: tunnel --config /etc/cloudflared/config.yml run --token $${TUNNEL_TOKEN}
    volumes:
      - ./config.yml:/etc/cloudflared/config.yml
    env_file:
      - .env
    networks:
      - n8n-network
    depends_on:
      n8n:
        condition: service_healthy

volumes:
  n8n_data:

networks:
  n8n-network:
    driver: bridge
