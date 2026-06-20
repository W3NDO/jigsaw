defmodule Bsp.Layout do
  @moduledoc """
  	The Engine keeps track of the layout tree. It exposes the following methods

  	# Commands
    Layout.new/1
    Layout.split/4
    Layout.close/2
    Layout.swap/3
    Layout.resize/3
    Layout.focus/2

    # Queries
    Layout.panes/1
    Layout.find/2
    Layout.compute/2
    Layout.focused/1
    Layout.parent/2
    Layout.children/2
    Layout.serialize/1
    Layout.deserialize/1
    Layout.validate/1
  """

  alias Bsp.{Pane, Node}

  defstruct [:root, focused: nil]

  @type tree :: Pane.t() | Node.t()

  def new(%Pane{id: root_name} = root_pane) do
    %__MODULE__{root: root_pane}
  end

  def split(%__MODULE__{root: root} = layout, target_id, new_id, direction) do
    case do_split(root, target_id, new_id, direction) do
      {:ok, new_root} -> {:ok, %{layout | root: new_root}}
      :error -> :error
    end
  end

  # Found the pane to split
  defp do_split(%Pane{id: id}, id, new_id, direction) do
    {:ok,
     %Node{
       direction: direction,
       ratio: 0.5,
       left: %Pane{id: id},
       right: %Pane{id: new_id}
     }}
  end

  # Wrong pane
  defp do_split(%Pane{}, _, _, _) do
    :error
  end

  # Search the left first
  defp do_split(%Node{} = split, target_id, new_id, direction) do
    case do_split(split.left, target_id, new_id, direction) do
      {:ok, new_left} ->
        {:ok, %{split | left: new_left}}

      :error ->
        case do_split(split.right, target_id, new_id, direction) do
          {:ok, new_right} ->
            {:ok, %{split | right: new_right}}

          :error ->
            :error
        end
    end
  end

  # Close
  def close(%__MODULE__{root: root} = layout, pane_id) do
    case do_close(root, pane_id) do
      {:ok, new_root} ->
        {:ok, %{layout | root: new_root}}

      :error ->
        :error
    end
  end

  defp do_close(%Pane{id: id}, id) do
    {:ok, nil}
  end

  defp do_close(%Pane{}, _) do
    :error
  end

  defp do_close(%Node{} = node, pane_id) do
    case do_close(node.left, pane_id) do
      {:ok, nil} ->
        {:ok, node.right}

      {:ok, new_left} ->
        {:ok, %{node | left: new_left}}

      :error ->
        case do_close(node.right, pane_id) do
          {:ok, nil} ->
            {:ok, node.left}

          {:ok, new_right} ->
            {:ok, %{node | right: new_right}}

          :error ->
            :error
        end
    end
  end

  # Swap
  def swap(%__MODULE__{root: root} = layout, pane_1_id, pane_2_id) do
    case do_swap(root, pane_1_id, pane_2_id) do
      {:ok, swapped_node} -> %{layout | root: swapped_node}
      :error -> :error
    end
  end

  defp do_swap(%Pane{}), do: :error

  defp do_swap(
         %Node{
           left: %Pane{id: left_pane_id} = left_pane,
           right: %Pane{id: right_pane_id} = right_pane
         },
         left_pane_id,
         right_pane_id
       ), do: {:ok, %Node{right: left_pane, left: right_pane}}

  # resize/3
  def resize(layout, target_1, target_2), do: nil

  # focus/2
  def focus(layout, target), do: nil
end
