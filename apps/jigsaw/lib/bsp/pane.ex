defmodule Bsp.Pane do
  @moduledoc """
  Defines a pane.
  """

  defstruct [:id]

  @type t :: %__MODULE__{
          id: String.t()
        }
end
