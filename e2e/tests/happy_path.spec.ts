import { test, expect } from "@playwright/test";

test("business can onboard, receive a report, and view it", async ({ page }) => {
  const email = `e2e_${Date.now()}@example.com`;

  // Start from a clean mailbox to avoid flakiness.
  await page.goto("/dev/mailbox");
  const emptyMailbox = page.getByRole("button", { name: /empty mailbox/i });
  if (await emptyMailbox.isVisible()) {
    await emptyMailbox.click();
  }

  // Sign in via magic link (works even when confirmation is enabled).
  await page.goto("/sign-in");

  // No vendor branding.
  await expect(page.getByText(/ash framework/i)).toHaveCount(0);
  await expect(page.locator('img[src*="ash-framework"]')).toHaveCount(0);

  // Fill the email field inside the magic link form specifically (avoid ambiguity).
  const magicForm = page.locator("form", {
    has: page.getByRole("button", { name: /request magic link/i }),
  });
  await magicForm.getByRole("textbox", { name: /^email$/i }).fill(email);
  const requestMagicLink = magicForm.getByRole("button", { name: /request magic link/i });
  await requestMagicLink.click();
  // Give the server a moment to enqueue + render any response.
  await expect(requestMagicLink).toBeEnabled({ timeout: 10_000 });

  // Open the mailbox preview and click the sign-in link.
  await page.goto("/dev/mailbox");
  const mailboxEntry = page.getByRole("link", { name: /your login link/i }).first();

  // The mailbox is server-rendered; poll with reloads until the message arrives.
  for (let i = 0; i < 10; i++) {
    if (await mailboxEntry.isVisible()) break;
    await page.waitForTimeout(500);
    await page.reload();
  }

  await expect(mailboxEntry).toBeVisible({ timeout: 5_000 });
  await mailboxEntry.click();

  const emailFrame = page.frameLocator("iframe").first();
  const magicHref = await emailFrame.locator('a[href*="/magic_link/"]').first().getAttribute("href");
  expect(magicHref).toBeTruthy();
  await page.goto(magicHref!);
  await Promise.all([
    page.waitForURL((url) => !url.pathname.includes("/magic_link/"), { timeout: 15_000 }),
    page.getByRole("button", { name: /^sign in$/i }).click(),
  ]);

  // After auth, go to the app. Without an org, we should be redirected to onboarding.
  await page.goto("/app/issues");
  await expect(page).toHaveURL(/\/app\/onboarding/);

  const orgName = `E2E Org ${Date.now()}`;
  await page.getByRole("textbox", { name: /organization name/i }).fill(orgName);
  await page.getByRole("button", { name: /create organization/i }).click();
  await expect(page).toHaveURL(/\/app\/issues/);

  // Create a new location and use its reporter link.
  await page.goto("/app/locations");
  const locationName = `Locker room ${Date.now()}`;
  const createLocationForm = page.locator("form", {
    has: page.getByRole("button", { name: /create location/i }),
  });
  const nameInput = createLocationForm.locator('input[name="name"]');
  await expect(nameInput).toBeVisible();
  await nameInput.fill(locationName);
  await createLocationForm.getByRole("button", { name: /create location/i }).click();
  await expect(page.getByRole("row", { name: new RegExp(locationName, "i") })).toBeVisible();

  const lockerRoomLink = page
    .getByRole("row", { name: new RegExp(locationName, "i") })
    .locator('a[href*="/r/"]')
    .first();

  const reporterLink = await lockerRoomLink.getAttribute("href");
  expect(reporterLink).toBeTruthy();

  await page.goto(reporterLink!);

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

