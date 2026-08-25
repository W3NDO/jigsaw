defmodule Types.Direction do
  @moduledoc false

  # :horizontal -> split left/right.
  # :vertical -> split top/bottom
  @type t :: :horizontal | :vertical
end
