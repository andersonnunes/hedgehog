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
      Naive.Schema.Settings,
      __MODULE__,
      Naive.SymbolSupervisor
    )
  end

  def start_trading(symbol) do
    Core.ServiceSupervisor.start_worker(
      symbol,
      Naive.Repo,
      Naive.Schema.Settings,
      __MODULE__,
      Naive.SymbolSupervisor
    )
  end

  def stop_trading(symbol) do
    Core.ServiceSupervisor.stop_worker(
      symbol,
      Naive.Repo,
      Naive.Schema.Settings,
      __MODULE__,
      Naive.SymbolSupervisor
    )
  end

  def shutdown_trading(symbol) when is_binary(symbol) do
    case Core.ServiceSupervisor.get_pid(Naive.SymbolSupervisor, symbol) do
      nil ->
        Logger.warning("#{Naive.SymbolSupervisor} worker for #{symbol} already stopped")

        {:ok, _settings} =
          Core.ServiceSupervisor.update_status(
            symbol,
            "off",
            Naive.Repo,
            Naive.Schema.Settings
          )

      _pid ->
        Logger.info("Initializing shutdown of #{Naive.SymbolSupervisor} worker for #{symbol}")

        {:ok, settings} =
          Core.ServiceSupervisor.update_status(
            symbol,
            "shutdown",
            Naive.Repo,
            Naive.Schema.Settings
          )

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
