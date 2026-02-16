import { test, expect } from "@playwright/test";

test("home page loads", async ({ page }) => {
  await page.goto("/");
  await expect(page).toHaveTitle(/CloseTheLoop/i);
});

test("sign-in page loads", async ({ page }) => {
  await page.goto("/sign-in");
  await expect(page).toHaveURL(/\/sign-in/);
  // AshAuthentication.Phoenix pages don't guarantee a visible heading.
  await expect(page.getByRole("textbox", { name: /email/i }).first()).toBeVisible();
  await expect(page.getByRole("textbox", { name: /password/i }).first()).toBeVisible();
  await expect(page.getByRole("button", { name: /^sign in$/i })).toBeVisible();
});

