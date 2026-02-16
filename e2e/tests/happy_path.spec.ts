import { test, expect } from "@playwright/test";

test("business can onboard, receive a report, and view it", async ({ page }) => {
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
    page.waitForURL(/\/app\//, { timeout: 30_000 }),
    (async () => {
      // There are 2 "Email" fields on this page (password + magic link).
      // The password form appears first.
      await page.getByRole("textbox", { name: /^email$/i }).first().fill(email);
      await page.getByRole("textbox", { name: /^password$/i }).fill(password);
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
  await expect(page).toHaveURL(/\/app\/[^/]+\/issues/);

  {
    const url = new URL(page.url());
    const parts = url.pathname.split("/");
    // /app/:org_id/issues
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
  const locationName = `Locker room ${Date.now()}`;
  const nameInput = page.getByRole("textbox", { name: /^name$/i });
  await expect(nameInput).toBeVisible();
  await nameInput.fill(locationName);
  await page.getByRole("button", { name: /create location/i }).click();
  await expect(page.getByText(new RegExp(locationName, "i"))).toBeVisible({
    timeout: 30_000,
  });

  const lockerRoomLink = page.locator("tr", { hasText: new RegExp(locationName, "i") }).locator('a[href*="/r/"]');

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
  await page.waitForURL(/\/app\/[^/]+\/issues\/.+/, { timeout: 20_000 });
  await expect(page.getByRole("heading", { name: /cold water/i })).toBeVisible({ timeout: 20_000 });

  await page.goto(reporterLink!);
  await page.waitForFunction(() => (window as any).liveSocket?.isConnected?.(), { timeout: 20_000 });

  await page.locator('textarea[name="report[body]"]').fill(reportBody);
  await expect(page.locator('textarea[name="report[body]"]')).toHaveValue(reportBody);
  await page.locator('input[name="report[phone]"]').fill("+15555555555");
  await page.getByRole("checkbox", { name: /agree to receive text updates/i }).check();
  await page.getByRole("button", { name: /^submit$/i }).click();
  await expect(page.getByText(/got it/i)).toBeVisible({ timeout: 20_000 });

  // Back on the issues list, verify we can see and open the issue + report.
  await page.goto(`/app/${orgId}/issues`);
  await expect(page.locator("#issues-list")).toBeVisible({ timeout: 20_000 });
  await expect(page.getByText(/cold water/i).first()).toBeVisible({ timeout: 20_000 });

  // Click the issue card to open it.
  await page.locator('a[id^="issue-"]', { hasText: /cold water/i }).first().click();

  await expect(page.getByRole("heading", { name: /cold water/i })).toBeVisible();
  await expect(page.getByText(reportBody).first()).toBeVisible();

  // Send an update (we don't validate SMS delivery, just that the action succeeds).
  await page.locator("#issue-open-send-sms").click();
  await expect(page.locator("#issue-send-sms-form")).toBeVisible({ timeout: 20_000 });

  await page.locator("#issue-send-sms-form textarea").fill("Thanks - we are on it.");
  await page.getByRole("checkbox", { name: /i understand this will send an sms/i }).check();
  await page.locator("#issue-send-sms-form").getByRole("button", { name: /^send sms$/i }).click();
  await expect(page.locator("#flash-info").getByText(/update queued/i)).toBeVisible();
});

