defmodule Eidolon.Compare do
  alias MyXQL, as: DB

  def compare(source_name, target_name, source, target, ignored_schemas) do
    require Logger
    Logger.info("[#{source_name} -> #{target_name}] Starting comparison")

    {:ok, src} = Eidolon.Connection.connect(Map.to_list(source) ++ [protocol: :tcp])
    {:ok, tgt} = Eidolon.Connection.connect(Map.to_list(target) ++ [protocol: :tcp])

    src_dbs = list_databases(src, ignored_schemas)
    tgt_dbs = list_databases(tgt, ignored_schemas)

    Enum.each(src_dbs, fn db ->
      if db not in tgt_dbs do
        Logger.warning("[#{source_name} -> #{target_name}] Missing database in target: #{db}")
      else
        compare_tables(src, tgt, db, source_name, target_name)
      end
    end)
  end

  defp list_databases(conn, ignored_schemas) do
    {:ok, result} = DB.query(conn, "SHOW DATABASES;")

    result.rows
    |> Enum.map(&hd/1)
    |> Enum.reject(&(&1 in ignored_schemas))
  end

  defp compare_tables(src, tgt, db, source_name, target_name) do
    require Logger
    Logger.info("[#{source_name} -> #{target_name}] [#{db}] Comparing tables")

    {:ok, src_tables} = DB.query(src, "SHOW TABLES FROM #{db};")
    {:ok, tgt_tables} = DB.query(tgt, "SHOW TABLES FROM #{db};")

    src_tables = Enum.map(src_tables.rows, &hd/1)
    tgt_tables = Enum.map(tgt_tables.rows, &hd/1)

    Enum.each(src_tables, fn tbl ->
      if tbl not in tgt_tables do
        Logger.warning(
          "[#{source_name} -> #{target_name}] [#{db}] Missing table in target: #{tbl}"
        )
      else
        compare_table_contents(
          src,
          tgt,
          db,
          tbl,
          source_name,
          target_name
        )
      end
    end)
  end

  defp compare_table_contents(src, tgt, db, tbl, source_name, target_name) do
    require Logger
    Logger.info("[#{source_name} -> #{target_name}] [#{db}.#{tbl}] Comparing table contents")

    row_count(src, db, tbl)
    |> compare_value(
      row_count(tgt, db, tbl),
      "Row count",
      db,
      tbl,
      source_name,
      target_name
    )

    checksum(src, db, tbl)
    |> compare_value(
      checksum(tgt, db, tbl),
      "Checksum",
      db,
      tbl,
      source_name,
      target_name
    )

    auto_inc(src, db, tbl)
    |> compare_value(
      auto_inc(tgt, db, tbl),
      "Auto increment",
      db,
      tbl,
      source_name,
      target_name
    )
  end

  defp row_count(conn, db, tbl) do
    {:ok, res} = DB.query(conn, "SELECT COUNT(*) FROM #{db}.#{tbl}")
    res.rows |> hd() |> hd()
  end

  defp checksum(conn, db, tbl) do
    {:ok, res} = DB.query(conn, "CHECKSUM TABLE #{db}.#{tbl}")
    res.rows |> hd() |> List.last()
  end

  defp auto_inc(conn, db, tbl) do
    {:ok, res} = DB.query(conn, "SHOW TABLE STATUS FROM #{db} LIKE '#{tbl}';")
    # Auto_increment
    res.rows |> hd() |> Enum.at(10)
  end

  defp compare_value(a, b, label, db, tbl, source_name, target_name) do
    require Logger

    if a != b do
      Logger.warning(
        "[#{source_name} -> #{target_name}] [#{db}.#{tbl}] #{label} mismatch: source=#{a}, target=#{b}"
      )
    else
      Logger.info("[#{source_name} -> #{target_name}] [#{db}.#{tbl}] #{label} matches: #{a}")
    end
  end
end
