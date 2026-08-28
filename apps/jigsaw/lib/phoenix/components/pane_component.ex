defmodule Phoenix.Components.PaneComponent do
  @moduledoc false
  use Phoenix.Component

  attr(:id, :string, required: true)
  slot(:inner, required: true)

  def pane(assigns) do
    ~H"""
    <div class="">
      {render_slot(@inner)}
    </div>
    """
  end
end
