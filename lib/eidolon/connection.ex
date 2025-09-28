defmodule Eidolon.Connection do
  alias MyXQL, as: DB

  def connect(config) do
    require Logger

    config = Enum.into(config, %{})

    new_config = %{
      hostname: Map.get(config, "host"),
      port: Map.get(config, "port"),
      username: Map.get(config, "username"),
      password: Map.get(config, "password")
    }

    config_as_keyword_list = Enum.into(new_config, [])

    case DB.start_link(config_as_keyword_list) do
      {:ok, conn} ->
        {:ok, conn}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def disconnect(conn) do
    GenServer.stop(conn)
  end
end
