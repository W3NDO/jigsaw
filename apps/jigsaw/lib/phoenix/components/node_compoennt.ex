defmodule Phoenix.Components.NodeComponent do
  @moduledoc false
  use Phoenix.Component

  attr(:id, :string)

  slot(:left_child)
  slot(:right_child)

  def node(assigns) do
    ~H"""
      <div>
        <div>{render_slot(@left_child)}</div>
        <div>{render_slot(@right_child)}</div>
      </div>
    """
  end
end
