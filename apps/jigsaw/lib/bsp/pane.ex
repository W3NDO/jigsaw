defmodule Bsp.Pane do
  @moduledoc """
  Defines a pane.

  A pane should have a way to calculate its width & height. It should inherit the size from the parent node?
  """

  alias Types.PaneShape

  defstruct [:id, :shape]

  @type t :: %__MODULE__{
          id: String.t(),
          shape: PaneShape.t()
        }
end
