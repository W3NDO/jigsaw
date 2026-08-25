defmodule Types.PaneId do
  @moduledoc false

  @type t :: String.t()

  def gen_id,
    do: :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
end
