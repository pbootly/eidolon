defmodule Eidolon.Config do
  @moduledoc """
  Reads the toml configuration for sources and targets.
  """

  def load(path) do
    path
    |> File.read!()
    |> Toml.decode!()
  end
end
