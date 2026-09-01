defmodule JigsawComponents.Components do
  @moduledoc """
  Provides Phoenix LiveView components for rendering and interacting with Jigsaw layouts.

  The components act as the presentation layer for the Jigsaw BSP layout engine. A Bsp.Layout describes the structure of the layout, while the components transform that structure into a hierarchy of HTML elements containing user-provided Phoenix slots.

  A Jigsaw layout can be rendered by providing a Bsp.Layout and defining a slot for each pane:
  ```
    <JigsawComponents.Components.layout jigsaw_layout={@jigsaw_layout}>
      <:pane id="terminal">
        <MyApp.Terminal />
      </:pane>

      <:pane id="about">
        <MyApp.About />
      </:pane>

      <:pane id="stats">
        <MyApp.Stats />
      </:pane>
    </JigsawComponents.Components.layout>
  ```

  The id of each :pane slot corresponds to the ID of a Bsp.Pane in the layout. Jigsaw uses this ID to associate the supplied content with its corresponding pane.

  ## Pane slots

  The `:pane` slot accepts the following attributes:

  id — identifies the pane and must correspond to a pane in the Bsp.Layout.
  focused — indicates whether the pane is currently focused. Default should be false.

  The component does not require the content of a pane to be a particular type of component. Any valid HEEx content can be placed inside a pane.

  The component does not own the layout itself. Layout manipulation should be performed through the Bsp.Layout API.
  """

  use Phoenix.Component

  alias Bsp.{Layout, Node, Pane}

  attr(:id, :string, default: "root")
  attr(:jigsaw_layout, :map, required: true)

  slot :pane, required: true do
    attr(:id, :string, required: true)
    attr(:focused, :boolean)
  end

  def layout(assigns) do
    ~H"""
    <div class="h-full w-full">
      {render_tree(@jigsaw_layout, @pane)}
    </div>
    """
  end

  defp render_tree(%Layout{root: %Pane{} = pane}, slots) do
    assigns = %{
      pane: pane,
      slots: slots
    }

    ~H"""
    <div class="w-full h-full flex">
      <.node_or_pane pane={@pane} slots={@slots} />
    </div>
    """
  end

  defp render_tree(%Layout{root: nil}, slots) do
    assigns = %{
      slots: slots
    }

    ~H"""
    <div class="w-full h-full flex ">
    </div>
    """
  end

  defp render_tree(%Layout{root: %Node{} = node}, slots) do
    assigns = %{
      node: node,
      slots: slots
    }

    ~H"""
    <div class="w-full h-full flex">
      <.node_or_pane pane={@node} slots={@slots} />
    </div>
    """
  end

  defp node_or_pane(%{pane: %Pane{id: id}, slots: slots} = assigns) do
    slot = find_slot(slots, id)

    assigns = assign(assigns, :slot, slot)

    ~H"""
    <div id={@pane.id} class="flex h-full w-full flex-1 flex-col p-2 rounded-sm bg-slate-400">
      <%= if @slot do %>
        <div class={"w-full h-full #{if @slot.focused, do: "rounded-sm border border-red-500", else: ""}"}>
        <%= render_slot(@slot) %>
        </div>
      <% end %>
    </div>
    """
  end

  defp node_or_pane(
         %{
           pane: %Node{
             left: left_pane,
             right: right_pane,
             direction: direction
           },
           slots: slots
         } = assigns
       ) do
    flex_direction =
      case direction do
        :vertical -> "flex-col"
        :horizontal -> "flex-row"
      end

    assigns =
      assign(assigns,
        left_pane: left_pane,
        right_pane: right_pane,
        slots: slots,
        flex_direction: flex_direction
      )

    ~H"""
    <div class={"flex h-full min-h-0 min-w-0 flex-1 #{@flex_direction}"}>
      <.node_or_pane
        pane={@left_pane}
        slots={@slots}
      />

      <.node_or_pane
        pane={@right_pane}
        slots={@slots}
      />
    </div>
    """
  end

  defp find_slot(slots, id) do
    Enum.find(slots, &(&1[:id] == id))
  end
end
