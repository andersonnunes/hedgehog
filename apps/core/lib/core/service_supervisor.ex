defmodule Core.ServiceSupervisor do
  require Logger

  import Ecto.Query, only: [from: 2]

  def autostart_workers(repo, schema) do
    fetch_symbols_to_start(repo, schema)
    |> Enum.map(&start_worker(&1, repo, schema))
  end

  def start_worker(symbol, repo, schema) when is_binary(symbol) do
    case get_pid(symbol) do
      nil ->
        Logger.info("Starting trading of #{symbol}")
        {:ok, _settings} = update_status(symbol, "on", repo, schema)

        {:ok, _pid} =
          DynamicSupervisor.start_child(
            Naive.DynamicSymbolSupervisor,
            {Naive.SymbolSupervisor, symbol}
          )

      pid ->
        Logger.warning("Trading on #{symbol} already started")
        {:ok, _settings} = update_status(symbol, "on", repo, schema)
        {:ok, pid}
    end
  end

  def stop_worker(symbol, repo, schema) when is_binary(symbol) do
    case get_pid(symbol) do
      nil ->
        Logger.warning("Trading on #{symbol} already stopped")
        {:ok, _settings} = update_status(symbol, "off", repo, schema)

      pid ->
        Logger.info("Stopping trading of #{symbol}")

        :ok =
          DynamicSupervisor.terminate_child(
            Naive.DynamicSymbolSupervisor,
            pid
          )

        {:ok, _settings} = update_status(symbol, "off", repo, schema)
    end
  end

  def get_pid(symbol) do
  end

  def update_status(symbol, status, repo, schema)
      when is_binary(symbol) and is_binary(status) do
    repo.get_by(schema, symbol: symbol)
    |> Ecto.Changeset.change(%{status: status})
    |> repo.update()
  end

  defp start_symbol_supervisor(symbol) do
  end

  defp fetch_symbols_to_start(repo, schema) do
    repo.all(
      from(s in schema,
        where: s.status == "on",
        select: s.symbol
      )
    )
  end
end
