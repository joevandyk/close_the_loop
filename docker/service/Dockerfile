# syntax=docker/dockerfile:1.4
#
# Self-updating service image:
# - Clones/pulls the repo from main on an interval
# - Runs migrations (or reset on failure)
# - Restarts the running server process
#
# Note: this is intentionally NOT the production release Dockerfile at repo root.

ARG ELIXIR_VERSION=1.20.0-rc.1
ARG OTP_VERSION=28.3.1
ARG DEBIAN_VERSION=bullseye-20260202

FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    locales \
    build-essential \
    openssl \
    postgresql-client \
  && rm -rf /var/lib/apt/lists/*

# Locale (helps with Elixir/Unicode edge cases)
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Hex + Rebar (required for deps)
RUN mix local.hex --force && mix local.rebar --force

# Non-root user
RUN useradd -m -u 1000 -s /bin/bash app

WORKDIR /srv
RUN mkdir -p /srv/data && chown -R app:app /srv

COPY docker/service/entrypoint.sh /usr/local/bin/close-the-loop-service
RUN chmod 0755 /usr/local/bin/close-the-loop-service

USER app

# Defaults (override via docker-compose env)
ENV DATA_DIR=/srv/data
ENV APP_DIR=/srv/data/close_the_loop
ENV MIX_ENV=dev
ENV PORT=3000

ENV GIT_BRANCH=main
ENV UPDATE_INTERVAL_SECONDS=60
ENV AUTO_RESET_ON_MIGRATION_FAILURE=true
ENV SEED_ON_RESET=true

EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/close-the-loop-service"]
