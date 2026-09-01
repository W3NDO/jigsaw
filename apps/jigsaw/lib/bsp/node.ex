defmodule Bsp.Node do
  @moduledoc """
  Node represents a split in the layout with a left and right side. Direction represents the direction of the split. Ratio at the moment is unused.
  """

  alias Types.Id

  @type t :: %__MODULE__{
          id: Id.t(),
          direction: Types.Direction.t(),
          ratio: float(),
          left: Bsp.Pane.t(),
          right: Bsp.Pane.t()
        }

  defstruct [:id, :direction, :ratio, :left, :right]
end
