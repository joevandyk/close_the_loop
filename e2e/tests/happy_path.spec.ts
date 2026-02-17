import { test, expect } from "@playwright/test";

test("business can onboard, receive a report, and view it", async ({ page }) => {
  // This flow depends on an async Oban job that calls OpenAI. It can take longer
  // than the default 30s timeout, and the Issues LiveView doesn't auto-refresh
  // when new issues are inserted, so we poll with reloads.
  test.setTimeout(120_000);

  const email = "e2e_owner@example.com";
  const password = "password1234";
  let orgId: string | null = null;

  // Sign in via password (avoid /dev/mailbox).
  await page.goto("/sign-in");
  await page.waitForFunction(() => (window as any).liveSocket?.isConnected?.(), { timeout: 20_000 });

  // No vendor branding.
  await expect(page.getByText(/ash framework/i)).toHaveCount(0);
  await expect(page.locator('img[src*="ash-framework"]')).toHaveCount(0);

  await Promise.all([
    // LiveView navigation often doesn't trigger a full page load.
    page.waitForURL(/\/app\//, { timeout: 30_000, waitUntil: "commit" }),
    (async () => {
      // There are 2 "Email" fields on this page (password + magic link).
      // The password form appears first.
      await page.getByRole("textbox", { name: /^email$/i }).first().fill(email);
      // There are multiple password inputs (sign-in + registration), so pick the first.
      await page.getByRole("textbox", { name: /^password$/i }).first().fill(password);
      await page.getByRole("button", { name: /^sign in$/i }).click();
    })(),
  ]);

  // After auth, go to the app. Without an org, we should be redirected to onboarding.
  await page.goto("/app");
  await expect(page).toHaveURL(/\/app\/onboarding/);

  await page.waitForFunction(() => (window as any).liveSocket?.isConnected?.(), { timeout: 20_000 });

  const orgName = `[E2E] Org ${Date.now()}`;
  await page.getByRole("textbox", { name: /organization name/i }).fill(orgName);
  await page.getByRole("button", { name: /create organization/i }).click();
  // New orgs land on the "Getting started" onboarding checklist.
  await expect(page).toHaveURL(/\/app\/[^/]+\/onboarding/);

  {
    const url = new URL(page.url());
    const parts = url.pathname.split("/");
    // /app/:org_id/onboarding
    orgId = parts[2] ?? null;
    expect(orgId).toBeTruthy();
  }

  // Save AI settings (regression: button must be clickable and submit successfully).
  await page.goto(`/app/${orgId}/settings/issue-categories`);
  await page.waitForFunction(() => (window as any).liveSocket?.isConnected?.(), { timeout: 20_000 });

  // Wait for LiveView to fully hydrate the page (data-phx-id appears after join).
  await expect(page.locator("#save-ai-settings-button")).toHaveAttribute("data-phx-id", /phx-/i, {
    timeout: 20_000,
  });

  await page.locator("#ai_business_context").fill("We run a gym with locker rooms and saunas.");
  await page
    .locator("#ai_categorization_instructions")
    .fill("If it mentions showers, drains, leaks, or water temp then plumbing.");

  // Sanity: the inputs must be in the same form.
  await expect(page.locator("#ai_business_context")).toHaveValue(
    "We run a gym with locker rooms and saunas."
  );
  await expect(page.locator("#ai_categorization_instructions")).toHaveValue(
    "If it mentions showers, drains, leaks, or water temp then plumbing."
  );

  await page.locator("#save-ai-settings-button").click();
  await expect(page.locator("#ai-settings-status")).toHaveAttribute("data-state", "saved", {
    timeout: 20_000,
  });

  // Ensure settings persist after reload.
  await page.reload();
  await page.waitForFunction(() => (window as any).liveSocket?.isConnected?.(), { timeout: 20_000 });
  await expect(page.locator("#ai_business_context")).toHaveValue(
    "We run a gym with locker rooms and saunas."
  );

  // Create a new location and use its reporter link.
  await page.goto(`/app/${orgId}/settings/locations`);
  // Ensure LiveView JS is loaded + connected before interacting.
  await page.waitForFunction(() => (window as any).liveSocket?.isConnected?.(), { timeout: 20_000 });
  await expect(page).toHaveURL(/\/app\/[^/]+\/settings\/locations/);
  // Wait for the LiveView to finish hydrating (so phx-click reaches the server).
  await expect(page.locator("#location-modal")).toHaveAttribute("data-phx-id", /phx-/i, {
    timeout: 20_000,
  });
  const locationName = `Locker room ${Date.now()}`;
  await page.locator("#locations-open-new").click();

  const locationModal = page.locator("#location-modal");
  await expect(locationModal).toHaveAttribute("data-open", "true", { timeout: 20_000 });
  await expect(locationModal).not.toHaveAttribute("hidden", { timeout: 20_000 });

  const nameInput = page.locator("#location-modal-name");
  await expect(nameInput).toBeVisible({ timeout: 20_000 });
  await nameInput.fill(locationName);
  await page.getByRole("button", { name: /create location/i }).click();
  await expect(page.getByText(new RegExp(locationName, "i"))).toBeVisible({
    timeout: 30_000,
  });

  const locationCard = page.locator("[data-location-card]", { hasText: new RegExp(locationName, "i") });
  const lockerRoomLink = locationCard.locator('a[href*="/r/"]').first();

  const reporterLink = await lockerRoomLink.getAttribute("href");
  expect(reporterLink).toBeTruthy();

  // Manual entry: front desk can log a report.
  const locationId = reporterLink!.split("/").pop();
  expect(locationId).toBeTruthy();

  await page.goto(`/app/${orgId}/reports/new?location_id=${locationId}`);
  await page.waitForFunction(() => (window as any).liveSocket?.isConnected?.(), { timeout: 20_000 });
  await expect(page.locator("#manual-report-form")).toBeVisible();

  const reportBody = "Cold water in the men's showers";
  await page.locator("#manual-body").fill(reportBody);
  await expect(page.locator("#manual-body")).toHaveValue(reportBody);
  await page.getByRole("button", { name: /add report/i }).click();
  await page.waitForURL(/\/app\/[^/]+\/(issues|reports)\/.+/, { timeout: 30_000, waitUntil: "commit" });
  await expect(page.getByText(/cold water/i).first()).toBeVisible({ timeout: 20_000 });

  await page.goto(reporterLink!);
  await page.waitForFunction(() => (window as any).liveSocket?.isConnected?.(), { timeout: 20_000 });

  await page.locator('textarea[name="report[body]"]').fill(reportBody);
  await expect(page.locator('textarea[name="report[body]"]')).toHaveValue(reportBody);
  await page.locator('input[name="report[reporter_phone]"]').fill("+15555555555");
  await page.getByRole("checkbox", { name: /send me text updates/i }).check();
  await page.getByRole("button", { name: /^submit$/i }).click();
  await expect(page.getByText(/got it/i)).toBeVisible({ timeout: 20_000 });

  // Back on the issues list, verify we can see and open the issue + report.
  //
  // Important: issue creation happens asynchronously, and the Issues LiveView
  // doesn't subscribe to new-issue events. If we land here "too early", the DOM
  // will stay empty until we reload. So we poll by reloading the page.
  await page.goto(`/app/${orgId}/issues`);
  await page.waitForFunction(() => (window as any).liveSocket?.isConnected?.(), { timeout: 20_000 });
  await expect(page.locator("#issues-list")).toBeVisible({ timeout: 20_000 });

  const firstIssueLink = page.locator('a[id^="issue-"]').first();

  const startedAt = Date.now();
  const timeoutMs = 90_000;
  while (true) {
    if (await firstIssueLink.count()) break;
    if (Date.now() - startedAt > timeoutMs) {
      throw new Error(
        "Timed out waiting for an issue to appear. The async report->issue job may have failed or OpenAI may be misconfigured."
      );
    }

    await page.waitForTimeout(2000);
    await page.reload({ waitUntil: "commit" });
    await page.waitForFunction(() => (window as any).liveSocket?.isConnected?.(), { timeout: 20_000 });
    await expect(page.locator("#issues-list")).toBeVisible({ timeout: 20_000 });
  }

  // Issue titles can vary (AI categorization/dedupe), so open the first issue
  // and assert the report body is present.
  await expect(firstIssueLink).toBeVisible({ timeout: 20_000 });
  await firstIssueLink.click();

  await expect(page.getByText(reportBody).first()).toBeVisible({ timeout: 20_000 });

  // Send an update (we don't validate SMS delivery, just that the action succeeds).
  const smsModal = page.locator("#issue-send-sms-modal");
  await expect(smsModal).toHaveAttribute("data-phx-id", /phx-/i, { timeout: 20_000 });
  await page.locator("#issue-open-send-sms").click();
  await expect(smsModal).toHaveAttribute("data-open", "true", { timeout: 20_000 });
  await expect(page.locator("#issue-send-sms-form")).toBeVisible({ timeout: 20_000 });

  await page.locator("#issue-send-sms-form textarea").fill("Thanks - we are on it.");
  await page.getByRole("checkbox", { name: /i understand this will send an sms/i }).check();
  await page.locator("#issue-send-sms-form").getByRole("button", { name: /^send sms$/i }).click();
  await expect(page.locator("#flash-info").getByText(/update queued/i)).toBeVisible();
});

