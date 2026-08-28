defmodule Phoenix.Components.JigsawComponent do
  @moduledoc false
  use Phoenix.Component

  attr(:id, :string, default: "root")
  attr(:layout, :map, required: true)

  def layout(_assigns) do
  end
end
