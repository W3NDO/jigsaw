defmodule Bsp.Node do
  @moduledoc """
  Node represents a split.
  """

  @type t :: %__MODULE__{
          id: String.t(),
          direction: Types.Direction.t(),
          ratio: float(),
          left: Bsp.Pane.t(),
          right: Bsp.Pane.t()
        }

  defstruct [:id, :direction, :ratio, :left, :right]
end
