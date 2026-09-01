defmodule Demo.Live.Home.Home do
  @moduledoc false
  use Demo, :live_view

  import Demo.CoreComponents

  alias Bsp.Layout

  def mount(_, _, socket) do
    jigsaw_layout = Bsp.Layout.new()

    assigns = %{
      active_panes: [],
      focused: nil,
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

        new_socket =
          socket
          |> assign(
            jigsaw_layout: new_layout,
            active_panes: new_active_panes,
            focused: new_layout.focused
          )

        {:noreply, new_socket}

      false ->
        {:ok, new_layout} = Layout.split(layout, focused_pane, pane_id)
        new_active_panes = new_layout.pane_ids

        new_socket =
          socket
          |> assign(
            jigsaw_layout: new_layout,
            active_panes: new_active_panes,
            focused: new_layout.focused
          )

        {:noreply, new_socket}
    end
  end

  def handle_event("close", %{"pane" => pane_id}, socket) do
    layout = socket.assigns.jigsaw_layout
    {:ok, new_layout} = Layout.close(layout, pane_id)

    {:noreply,
     socket
     |> assign(
       jigsaw_layout: new_layout,
       active_panes: new_layout.pane_ids,
       focused: new_layout.focused
     )}
  end

  def handle_event("jigsaw-key-shortcuts", %{"ctrlKey" => true, "key" => key}, socket) do
    case Enum.member?(["1", "2", "3", "4", "5", "6", "7", "8", "9"], key) do
      false ->
        {:noreply, socket}

      true ->
        available_panes = socket.assigns.available_panes_id
        layout = socket.assigns.jigsaw_layout

        pane = Enum.at(available_panes, String.to_integer(key) - 1)

        if pane == nil do
          {:noreply, socket}
        else
          {:ok, new_layout} = toggle_pane(layout, pane)

          new_socket =
            socket
            |> assign(
              jigsaw_layout: new_layout,
              active_panes: new_layout.pane_ids,
              focused: new_layout.focused
            )

          {:noreply, new_socket}
        end
    end
  end

  def handle_event("jigsaw-key-shortcuts", %{"ctrlKey" => false, "key" => _}, socket),
    do: {:noreply, socket}

  defp toggle_pane(layout, pane) do
    case Enum.member?(layout.pane_ids, pane) do
      true -> Layout.close(layout, pane)
      false -> Layout.split(layout, layout.focused, pane)
    end
  end
end
