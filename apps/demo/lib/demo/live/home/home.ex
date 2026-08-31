defmodule Demo.Live.Home.Home do
  use Demo, :live_view

  import Jigsaw
  import Demo.CoreComponents

  alias Bsp.Layout

  def mount(_, _, socket) do
    jigsaw_layout = Bsp.Layout.new
    assigns = %{
      active_panes: [],
      available_panes_id: ["terminal", "music", "about"],
      jigsaw_layout: jigsaw_layout
    }

    {:ok, socket |> assign(assigns)}
  end

  def handle_event("toggle-pane", %{"pane" => pane_id}, socket) do
    active_panes = socket.assigns.active_panes
    layout = socket.assigns.jigsaw_layout
    focused_pane = Layout.focused!(layout)

    case Enum.member?(active_panes, pane_id) do
      true ->
        {:ok, new_layout} = Layout.close(layout, pane_id)
        new_active_panes = new_layout.pane_ids

        new_socket = socket |> assign(jigsaw_layout: new_layout, active_panes: new_active_panes)

        {:noreply, new_socket}

      false ->
        {:ok, new_layout} = Layout.split(layout, focused_pane, pane_id)
        new_active_panes = new_layout.pane_ids

        new_socket = socket |> assign(jigsaw_layout: new_layout, active_panes: new_active_panes)

        {:noreply, new_socket}
    end

  end

  def handle_event("close", %{"pane" => pane_id}, socket) do
    layout = socket.assigns.jigsaw_layout
    {:ok, new_layout} = Layout.close(layout, pane_id)
    {:noreply, socket |> assign(jigsaw_layout: new_layout, active_panes: new_layout.pane_ids)}
  end
end
