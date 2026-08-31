defmodule JigsawComponents.Components do
  @moduledoc false

  use Phoenix.Component

  alias Bsp.{Layout, Pane, Node}

  attr :id, :string, default: "root"
  attr :jigsaw_layout, :map, required: true

  slot :pane, required: true do
    attr :id, :string, required: true
    attr :hidden, :boolean
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
      pane: pane, slots: slots
    }
    ~H"""
    <div class="w-full h-full flex">
      <.node_or_pane pane={pane} slots={slots} />
    </div>
    """
  end

  defp render_tree(%Layout{root: nil}, slots) do
    assigns = %{
    }
    ~H"""
    <div class="w-full h-full flex ">
    </div>
    """
  end

  defp render_tree(%Layout{root: %Node{} = node}, slots) do
    assigns = %{
      pane: node, slots: slots
    }
    ~H"""
    <div class="w-full h-full flex">
      <.node_or_pane pane={node} slots={slots} />
    </div>
    """
  end

  def node_or_pane(%{pane: %Pane{id: id}, slots: slots} = assigns) do
    slot = find_slot(slots, id)

    assigns = assign(assigns, :slot, slot)

    ~H"""
    <div id={@pane.id} class="flex h-full w-full flex-1 flex-col p-2 rounded-sm bg-slate-400">
      <%= if @slot do %>
        <div class="w-full h-full">
        <%= render_slot(@slot) %>
        </div>
      <% end %>
    </div>
    """
  end

  def node_or_pane(
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
