defmodule Naive.DynamicSymbolSupervisor do
  use DynamicSupervisor

  require Logger

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def autostart_workers do
    Core.ServiceSupervisor.autostart_workers(
      Naive.Repo,
      Naive.Schema.Settings
    )
  end

  def start_trading(symbol) do
    Core.ServiceSupervisor.start_worker(
      symbol,
      Naive.Repo,
      Naive.Schema.Settings
    )
  end

  def stop_trading(symbol) do
    Core.ServiceSupervisor.stop_worker(
      symbol,
      Naive.Repo,
      Naive.Schema.Settings
    )
  end

  def shutdown_trading(symbol) when is_binary(symbol) do
    case Core.ServiceSupervisor.get_pid(symbol) do
      nil ->
        Logger.warning("Trading on #{symbol} already stopped")
        {:ok, _settings} = Core.ServiceSupervisor.update_status(symbol, "off")

      _pid ->
        Logger.info("Shutdown of trading on #{symbol} initialized")
        {:ok, settings} = Core.ServiceSupervisor.update_status(symbol, "shutdown")
        Naive.Leader.notify(:settings_updated, settings)
        {:ok, settings}
    end
  end

  def start_symbol_supervisor(symbol) do
    DynamicSupervisor.start_child(
      Naive.DynamicSymbolSupervisor,
      {Naive.SymbolSupervisor, symbol}
    )
  end
end
