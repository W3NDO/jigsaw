defmodule Bsp.Geometry do
  @moduledoc """
  Calculates the geometry of all the panes.
  """

  alias Bsp.{Layout, Pane, Node}

  defstruct [:id, :position, :width, :height]

  @type t :: %{id: String.t(), position: {number(), number()}}

  @spec calculate(Layout.t()) :: list(t())
  def calculate(%Layout{root: %Node{}}) do
    []
  end

  def calculate(%Layout{root: %Pane{id: id}}),
    do: [%__MODULE__{id: id, position: {0, 0}, width: 100, height: 100}]
end
