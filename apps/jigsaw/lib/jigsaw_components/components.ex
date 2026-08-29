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
    <div>
      {render_tree(@jigsaw_layout, @pane)}
    </div>
    """
  end

  defp render_tree(%Layout{root: %Pane{} = pane}, slots) do
    assigns = %{
      pane: pane, slots: slots
    }
    ~H"""
    <div class="w-full h-full flex-1 m-2 p-2" data-value="bingo">
      <.node_or_pane pane={pane} slots={slots} />
    </div>
    """
  end

  defp render_tree(%Layout{root: nil}, slots) do
    assigns = %{
    }
    ~H"""
    <div class="w-full h-full flex-1 m-2 p-2">
      <h1> No Active Panes </h1>
    </div>
    """
  end

  defp render_tree(%Layout{root: %Node{} = node}, slots) do
    assigns = %{
      pane: node, slots: slots
    }
    ~H"""
    <div class="w-full h-full flex-1 m-2 p-2">
      <.node_or_pane pane={node} slots={slots} />
    </div>
    """
  end

  def node_or_pane(%{pane: %Pane{id: id}, slots: slots} = assigns) do
    slot = find_slot(slots, id)

    assigns = assign(assigns, :slot, slot)

    ~H"""
    <div id={@pane.id} class="w-full h-full flex-1 m-2 p-2">
      <%= if @slot do %>
        <div>
          <div>
            <.application_control_buttons pane={@pane} />
          </div>
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
    <div class={"flex flex-1 w-full h-full #{ @flex_direction }"}>
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

  attr :pane, :map, required: true
  # close, minimize, expand
  def application_control_buttons(assigns) do
    ~H"""
    <div class="w-full flex items-right gap-1.5">
        <!-- Close -->
        <button
          type="button"
          phx-click="close"
          phx-value-pane={@pane.id}
          aria-label="Close"
          class="group flex h-4 w-4 items-center justify-center rounded-full bg-red-500 hover:bg-red-600"
        >
          x
        </button>

        <!-- Minimize -->
        <button
          type="button"
          phx-click="minimize"
          phx-value-pane={@pane.id}
          aria-label="Minimize"
          class="group flex h-4 w-4 items-center justify-center rounded-full bg-yellow-500 hover:bg-yellow-600"
        >
          -
        </button>
      </div>
    """

  end
end
