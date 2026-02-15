import { defineConfig } from "@playwright/test";

const port = process.env.E2E_PORT ?? "41731";

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
        // Use a dedicated port to avoid accidentally reusing an unrelated service
        // on :3000 (a common dev port).
        //
        // We run through Doppler so DATABASE_URL/SECRET_KEY_BASE/etc come from
        // your Doppler config, but we still force the port for test stability.
        command: `bash -lc "cd .. && doppler run --preserve-env -- env PORT=${port} MIX_ENV=dev bash -lc 'mix ecto.create && mix ecto.migrate && mix phx.server'"`,
        url: `http://localhost:${port}`,
        reuseExistingServer: false,
        timeout: 120_000,
      },
});

