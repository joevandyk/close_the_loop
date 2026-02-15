defmodule Fluxon.MixProject do
  use Mix.Project

  @version "2.3.1"

  def project do
    [
      app: :fluxon,
      version: @version,
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: "Fluxon UI Components",
      name: "Fluxon",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      files: ~w(lib priv mix.exs package.json usage-rules.md  CHANGELOG.md),
      maintainers: ["Andriel Nuernberg"],
      licenses: ["Commercial"],
      links: %{"Website" => "https://fluxonui.com"}
    ]
  end

  defp docs do
    [
      main: "overview",
      api_reference: false,
      logo: "assets/fluxon-logo.svg",
      favicon: "assets/fluxon-favicon.svg",
      source_ref: "v#{@version}",
      extra_section: "GUIDES",
      homepage_url: "/",
      formatters: ["html"],
      groups_for_extras: groups_for_extras(),
      groups_for_modules: groups_for_modules(),
      groups_for_docs: [Components: &(&1[:type] == :component)],
      extras: extras(),
      assets: %{"assets/docs/images" => "images", "assets/docs/js" => "js", "assets/docs/css" => "css"},
      before_closing_head_tag: fn _ ->
        """
        <script src="js/preview.js"></script>
        <link rel="stylesheet" href="css/preview.css" />
        """
      end,
      before_closing_body_tag: fn _ ->
        """
        <script>document.querySelector('footer.footer p').remove()</script>
        """
      end
    ]
  end

  def extras do
    [
      # Introduction
      "guides/intro/overview.md",
      "guides/intro/gettext.md",
      "guides/deployment/fly.md",

      # Upgrading Guides
      "guides/upgrading/v2.0.md",

      # Changelog
      "CHANGELOG.md": [filename: "changelog", title: "Changelog"]
    ]
  end

  def groups_for_extras do
    [
      Introduction: ~r"guides/intro/",
      Deployment: ~r"guides/deployment/",
      Upgrading: ~r"guides/upgrading/"
    ]
  end

  def groups_for_modules do
    [
      Base: [
        Fluxon.Components.Accordion,
        Fluxon.Components.Alert,
        Fluxon.Components.Badge,
        Fluxon.Components.Button,
        Fluxon.Components.Loading,
        Fluxon.Components.Navlist,
        Fluxon.Components.Separator,
        Fluxon.Components.Table,
        Fluxon.Components.Tabs
      ],
      Overlay: [
        Fluxon.Components.Dropdown,
        Fluxon.Components.Modal,
        Fluxon.Components.Popover,
        Fluxon.Components.Sheet,
        Fluxon.Components.Tooltip
      ],
      Form: [
        Fluxon.Components.Autocomplete,
        Fluxon.Components.Checkbox,
        Fluxon.Components.DatePicker,
        Fluxon.Components.Form,
        Fluxon.Components.Input,
        Fluxon.Components.Radio,
        Fluxon.Components.Select,
        Fluxon.Components.Switch,
        Fluxon.Components.Textarea
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_live_view, ">= 1.0.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:makeup_eex, "~> 2.0.0", only: :dev},
      {:makeup_html, "~> 0.2.0", only: :dev},
      {:makeup_elixir, "~> 1.0", only: :dev},
      {:makeup_diff, "~> 0.1.1", only: :dev},
      {:floki, "~> 0.37.0", only: :test}
    ]
  end
end
