Mix.install([
  {:toml, "~> 0.7.0"},
  {:myxql, "~> 0.6"}
])

Code.compile_file("lib/eidolon/config.ex")
Code.compile_file("lib/eidolon/connection.ex")
Code.compile_file("lib/eidolon/compare.ex")
Code.compile_file("lib/eidolon.ex")

config = System.argv() |> List.first() || "compose-test.toml"

Eidolon.run(config)

