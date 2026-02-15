import { test, expect } from "@playwright/test";

test("business can onboard, receive a report, and view it", async ({ page }) => {
  const email = "e2e_owner@example.com";
  const password = "password1234";

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
  await page.goto("/app/issues");
  await expect(page).toHaveURL(/\/app\/onboarding/);

  await page.waitForFunction(() => (window as any).liveSocket?.isConnected?.(), { timeout: 20_000 });

  const orgName = `[E2E] Org ${Date.now()}`;
  await page.getByRole("textbox", { name: /organization name/i }).fill(orgName);
  await page.getByRole("button", { name: /create organization/i }).click();
  await expect(page).toHaveURL(/\/app\/issues/);

  // Create a new location and use its reporter link.
  await page.goto("/app/locations");
  // Ensure LiveView JS is loaded + connected before interacting.
  await page.waitForFunction(() => (window as any).liveSocket?.isConnected?.(), { timeout: 20_000 });
  const locationName = `Locker room ${Date.now()}`;
  const createLocationForm = page.locator("form", {
    has: page.getByRole("button", { name: /create location/i }),
  });
  const nameInput = createLocationForm.locator('input[name="name"]');
  await expect(nameInput).toBeVisible();
  await nameInput.fill(locationName);
  await createLocationForm.getByRole("button", { name: /create location/i }).click();
  await expect(page.getByRole("row", { name: new RegExp(locationName, "i") })).toBeVisible({
    timeout: 30_000,
  });

  const lockerRoomLink = page
    .getByRole("row", { name: new RegExp(locationName, "i") })
    .locator('a[href*="/r/"]')
    .first();

  const reporterLink = await lockerRoomLink.getAttribute("href");
  expect(reporterLink).toBeTruthy();

  await page.goto(reporterLink!);
  await page.waitForFunction(() => (window as any).liveSocket?.isConnected?.(), { timeout: 20_000 });

  const reportBody = "Cold water in the men's showers";
  await page.locator('textarea[name="report[body]"]').fill(reportBody);
  await page.locator('input[name="report[phone]"]').fill("+15555555555");
  await page.getByRole("checkbox", { name: /agree to receive text updates/i }).check();
  await page.getByRole("button", { name: /^submit$/i }).click();
  await expect(page.getByText(/got it/i)).toBeVisible({ timeout: 20_000 });

  // Back on the business inbox, verify we can see and open the issue + report.
  await page.goto("/app/issues");
  await expect(page.getByRole("row", { name: /cold water/i })).toBeVisible();
  await page.getByRole("row", { name: /cold water/i }).getByRole("link", { name: /view/i }).click();

  await expect(page.getByRole("heading", { name: /cold water/i })).toBeVisible();
  await expect(page.getByText(reportBody).first()).toBeVisible();

  // Send an update (we don't validate SMS delivery, just that the action succeeds).
  await page.locator('textarea[name="message"]').fill("Thanks - we are on it.");
  await page.getByRole("button", { name: /send update/i }).click();
  await expect(page.getByText(/update queued/i)).toBeVisible();
});

