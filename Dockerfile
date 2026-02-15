# syntax=docker/dockerfile:1

# ─── Build Stage ──────────────────────────────────────────────────────
ARG ELIXIR_VERSION=1.20.0-rc.1
ARG OTP_VERSION=28.3.1
ARG DEBIAN_VERSION=bullseye-20260202
ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS builder

ARG GIT_SHA=unknown
ARG APP_VERSION=unknown
ENV GIT_SHA=${GIT_SHA}
ENV APP_VERSION=${APP_VERSION}
ENV MIX_ENV=prod

WORKDIR /app

# Install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# Copy compile-time config
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv
COPY lib lib
COPY assets assets

# Compile assets
RUN mix assets.deploy

# Compile project
RUN mix compile

# Build release
COPY config/runtime.exs config/
RUN mix release

# ─── Runtime Stage ────────────────────────────────────────────────────
FROM ${RUNNER_IMAGE}

ARG GIT_SHA=unknown
ARG APP_VERSION=unknown
ENV GIT_SHA=${GIT_SHA}
ENV APP_VERSION=${APP_VERSION}

RUN apt-get update -y && \
    apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates wget \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR /app
RUN chown nobody /app

ENV MIX_ENV=prod
ENV PORT=3000

COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/close_the_loop ./

USER nobody

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=15s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["bin/close_the_loop", "start"]
