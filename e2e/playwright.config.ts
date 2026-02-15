import { defineConfig } from "@playwright/test";

// Dedicated port for e2e so it never conflicts with dev (4000) or other services.
const port = process.env.E2E_PORT ?? "41731";

// E2E runs the app in dev mode but against the test DB for isolation.
// Override with E2E_DATABASE_URL if your test Postgres is not on localhost.
const e2eDatabaseUrl =
  process.env.E2E_DATABASE_URL ??
  "postgres://postgres:postgres@localhost/close_the_loop_test";

export default defineConfig({
  testDir: "./tests",
  timeout: 60_000,
  expect: { timeout: 10_000 },
  use: {
    baseURL: process.env.BASE_URL ?? `http://localhost:${port}`,
    trace: "on-first-retry",
  },
  webServer: process.env.E2E_WEB_SERVER
    ? undefined
    : {
        command: `bash -lc "cd .. && doppler run --preserve-env -- env PORT=${port} MIX_ENV=dev MIX_BUILD_PATH=_build_e2e DATABASE_URL='${e2eDatabaseUrl}' bash -lc 'mix ecto.create && mix ash_postgres.migrate && mix run priv/repo/seeds.exs && mix run priv/repo/e2e_seeds.exs && mix phx.server'"`,
        url: `http://localhost:${port}`,
        reuseExistingServer: false,
        timeout: 180_000,
      },
});

