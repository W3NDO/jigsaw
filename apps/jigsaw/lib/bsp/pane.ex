defmodule Bsp.Pane do
  @moduledoc """
  Defines a pane.
  """

  alias Types.Id

  defstruct [:id]

  @type t :: %__MODULE__{
          id: Id.t()
        }
end
