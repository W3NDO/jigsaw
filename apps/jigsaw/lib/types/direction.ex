defmodule Types.Direction do
  @moduledoc """
  Specifies the directions allowed for splitting a node
  """

  # :horizontal -> split left/right.
  # :vertical -> split top/bottom
  @type t :: :horizontal | :vertical
end
