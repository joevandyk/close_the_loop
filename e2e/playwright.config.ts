import path from "path";
import { defineConfig } from "@playwright/test";

// Dedicated port for e2e so it never conflicts with dev (4000) or other services.
const port = process.env.E2E_PORT ?? "41731";

// Doppler CLI stores its config scoped to a directory. Worktrees live in a different
// filesystem path than the main checkout, so `doppler run` may not discover a
// previously-configured project/config. Make this explicit (but overrideable).
const dopplerProject = process.env.DOPPLER_PROJECT ?? "close-the-loop";
// In this repo, the main checkout typically uses the `local_close_the_loop`
// config; worktrees should match unless explicitly overridden.
const dopplerConfig = process.env.DOPPLER_CONFIG ?? "local_close_the_loop";

// E2E runs the app in dev mode but against the test DB for isolation.
// Use a per-worktree DB name so worktrees don't share one DB (avoids unique_violation
// when the DB already exists from another checkout). Override with E2E_DATABASE_URL.
function defaultE2eDatabaseUrl(): string {
  const projectRoot = path.resolve(process.cwd(), "..");
  const basename = path.basename(projectRoot);
  const sanitized = basename.replace(/[^a-z0-9_]/gi, "_").toLowerCase() || "default";
  const dbSuffix = sanitized === "close_the_loop" ? "" : `_${sanitized}`;
  const dbName = `close_the_loop_test${dbSuffix}`;
  return `postgres://postgres:postgres@localhost/${dbName}`;
}
const e2eDatabaseUrl =
  process.env.E2E_DATABASE_URL ?? defaultE2eDatabaseUrl();

export default defineConfig({
  testDir: "./tests",
  timeout: 30_000,
  expect: { timeout: 10_000 },
  use: {
    baseURL: process.env.BASE_URL ?? `http://localhost:${port}`,
    trace: "on-first-retry",
  },
  webServer: process.env.E2E_WEB_SERVER
    ? undefined
    : {
        command: `bash -lc "cd .. && doppler run --preserve-env -p '${dopplerProject}' -c '${dopplerConfig}' -- env PORT=${port} MIX_ENV=dev MIX_BUILD_PATH=_build_e2e DATABASE_URL='${e2eDatabaseUrl}' ./scripts/e2e_webserver.sh"`,
        url: `http://localhost:${port}`,
        reuseExistingServer: false,
        timeout: 180_000,
      },
});

