defmodule Components.PaneComponent do

  use Phoenix.Component

  slot :inner
  attr :id, :string, required: true


  def pane(assigns) do

  end
end
