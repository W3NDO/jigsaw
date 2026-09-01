defmodule Types.Id do
  @moduledoc """
  The type for an ID.
  """

  @type t :: String.t()

  @doc """
  Generates a random ID. Used by the `Node` & `Pane` struct.
  """
  @spec gen_id() :: String.t()
  def gen_id,
    do: :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
end
