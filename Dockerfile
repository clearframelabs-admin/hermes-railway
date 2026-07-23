FROM nousresearch/hermes-agent:main@sha256:3fb7724c7ccf85d2bd64813fbc506868d5e190aa6cff170d3c8c7eb8e5d8a2cf

# Install unzip (required for composio CLI install)
RUN apt-get update && apt-get install -y --no-install-recommends unzip && rm -rf /var/lib/apt/lists/*

# Install composio CLI
RUN curl -fsSL https://raw.githubusercontent.com/ComposioHQ/composio/master/install.sh | COMPOSIO_INSTALL_DIR=/opt/composio bash

COPY --chmod=0755 docker-entrypoint.sh /usr/local/bin/hermes-railway-entrypoint

ENV HERMES_HOME=/data/.hermes \
    HERMES_WRITE_SAFE_ROOT=/data/.hermes \
    HERMES_LAZY_INSTALL_TARGET=/data/.hermes/lazy-packages \
    HERMES_DASHBOARD=1 \
    HERMES_DASHBOARD_HOST=0.0.0.0 \
    HERMES_GATEWAY_BOOTSTRAP_STATE=running

ENTRYPOINT ["/usr/local/bin/hermes-railway-entrypoint"]
CMD ["gateway", "run"]
