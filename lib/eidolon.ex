defmodule Eidolon do
  alias Eidolon.{Config, Compare}

  def run(config_path) do
    cfg = Config.load(config_path)

    ignored_schemas = cfg["schemas"]["ignore"]["names"] || []

    tasks =
      Enum.map(cfg["target"], fn {target_key, target} ->
        Task.async(fn ->
          source_key = target["source"] |> String.split(".") |> tl() |> Enum.join(".")
          source = cfg["source"][source_key]

          Compare.compare(source_key, target_key, source, target, ignored_schemas)
        end)
      end)

    Enum.each(tasks, &Task.await/1)
  end
end
