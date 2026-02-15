FROM hexpm/elixir:1.20.0-rc.1-erlang-28.3.1-debian-bullseye-20260202

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    jq \
    make \
    build-essential \
    inotify-tools \
    postgresql-client \
    gnupg \
    apt-transport-https \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Doppler CLI (used by scripts/* wrappers)
RUN curl -sLf --retry 3 --tlsv1.2 --proto "=https" \
      "https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key" \
      | gpg --dearmor -o /usr/share/keyrings/doppler-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/doppler-archive-keyring.gpg] https://packages.doppler.com/public/cli/deb/debian any-version main" \
      > /etc/apt/sources.list.d/doppler-cli.list \
    && apt-get update \
    && apt-get install -y doppler \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24 (needed for Phoenix assets / Tailwind)
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Install Hex and Rebar
RUN mix local.hex --force && mix local.rebar --force

# Install Phoenix generator
RUN mix archive.install hex phx_new --force

# Install Igniter (for optional Ash scaffolding and other installer-driven deps)
RUN mix archive.install hex igniter_new --force

WORKDIR /workspace
