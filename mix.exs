defmodule EChat.MixProject do
  use Mix.Project

  def project do
    [
      app: :e_chat,
      description: "Chat, okay, chat.",
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex],
      mod: {EChat, []},
      env: [port: 8080]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, github: "ninenines/cowboy", tag: "2.9.0"},
      {:poison, "~> 5.0"},
      {:httpoison, "~> 1.8"},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end
end
