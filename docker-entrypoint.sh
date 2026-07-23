#!/bin/sh
set -eu

# Auto-login to composio if API key is set (don't crash if it fails)
if [ -n "${COMPOSIO_API_KEY:-}" ]; then
  echo "[DEBUG] Running as user: $(whoami)"
  echo "[DEBUG] HOME=$HOME"
  echo "[DEBUG] PATH=$PATH"
  echo "[DEBUG] COMPOSIO_API_KEY length: ${#COMPOSIO_API_KEY}"
  echo "[DEBUG] COMPOSIO_API_KEY prefix: ${COMPOSIO_API_KEY:0:8}..."
  echo "[DEBUG] Checking composio binary: $(ls -la /opt/composio/composio 2>&1)"
  echo "[DEBUG] Attempting composio login..."
  HOME=/opt/data PATH="/opt/composio:$PATH" composio login --user-api-key "$COMPOSIO_API_KEY" --no-skill-install 2>&1
  echo "[DEBUG] Composio exit code: $?"
fi

dashboard_username="${HERMES_DASHBOARD_BASIC_AUTH_USERNAME:-${ADMIN_USERNAME:-admin}}"
dashboard_password="${HERMES_DASHBOARD_BASIC_AUTH_PASSWORD:-${ADMIN_PASSWORD:-}}"

if [ -z "$dashboard_password" ]; then
    dashboard_password="$(python -c 'import secrets; print(secrets.token_urlsafe(16))')"
    echo "Generated admin password: $dashboard_password"
fi

dashboard_secret="${HERMES_DASHBOARD_BASIC_AUTH_SECRET:-}"
if [ -z "$dashboard_secret" ]; then
    dashboard_secret="$(
        ADMIN_PASSWORD="$dashboard_password" python -c \
            'import base64, hashlib, os; print(base64.b64encode(hashlib.sha256(("hermes-dashboard-session:" + os.environ["ADMIN_PASSWORD"]).encode()).digest()).decode())'
    )"
fi

export HERMES_DASHBOARD_PORT="${HERMES_DASHBOARD_PORT:-${PORT:-8080}}"
export HERMES_DASHBOARD_BASIC_AUTH_USERNAME="$dashboard_username"
export HERMES_DASHBOARD_BASIC_AUTH_PASSWORD="$dashboard_password"
export HERMES_DASHBOARD_BASIC_AUTH_SECRET="$dashboard_secret"

exec /init /opt/hermes/docker/main-wrapper.sh "$@"
