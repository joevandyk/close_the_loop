defmodule CloseTheLoop.DevSeedFixturesTest do
  use ExUnit.Case, async: true

  @fixtures_dir Path.expand("../../priv/repo/seed_fixtures", __DIR__)

  test "fixture locations do not include org name prefix" do
    for file <- fixture_files() do
      data = file |> File.read!() |> Jason.decode!()
      org_name = data["organization_name"]

      assert is_binary(org_name) and String.trim(org_name) != "",
             "expected organization_name in #{Path.basename(file)}"

      for loc <- data["locations"] do
        full_path = loc["full_path"] || ""

        refute full_path == org_name,
               "location full_path must not equal org name in #{Path.basename(file)}"

        refute String.starts_with?(full_path, org_name <> " / "),
               "location full_path must not include org name prefix in #{Path.basename(file)}: #{inspect(full_path)}"
      end
    end
  end

  test "fixtures include multiple reports per issue often" do
    for file <- fixture_files() do
      data = file |> File.read!() |> Jason.decode!()
      issues = data["issues"] || []

      total = max(length(issues), 1)
      multi = Enum.count(issues, fn i -> length(i["reports"] || []) > 1 end)

      # Some issues can have 1 report, but overall we prefer to see multiple reports often.
      assert multi / total >= 0.4,
             "expected >=40% multi-report issues in #{Path.basename(file)}, got #{multi}/#{total}"
    end
  end

  defp fixture_files do
    Path.wildcard(Path.join(@fixtures_dir, "org_*.json"))
  end
end
