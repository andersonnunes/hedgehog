defmodule Naive do
  @moduledoc """
  Documentation for `Naive`.
  """

  def start_trading(symbol) do
    symbol = String.upcase(symbol)

    {:ok, _íd} =
      DynamicSupervisor.start_child(
        Naive.DynamicSymbolSupervisor,
        {Naive.SymbolSupervisor, symbol}
      )
  end
end
