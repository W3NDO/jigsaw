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

  alias Bsp.{Node, Pane}
  alias Types.{Direction, PaneId}

  defstruct [:root, focused: nil, pane_ids: []]

  @type tree :: Pane.t() | Node.t()

  @spec new(Pane.t()) :: %__MODULE__{}
  def new(%Pane{id: root_name} = root_pane) do
    %__MODULE__{root: root_pane, focused: root_name, pane_ids: [root_name]}
  end

  def new(_), do: {:error, :invalid_layout}

  @spec split(%__MODULE__{}, PaneId.t(), PaneId.t(), Direction.t()) ::
          {:ok, %__MODULE__{}} | {:error, :pane_not_found} | {:error, :duplicate_pane_id}
  def split(%__MODULE__{root: root, pane_ids: pane_ids} = layout, target_id, new_id, direction) do
    case Enum.member?(pane_ids, new_id) do
      true ->
        {:error, :duplicate_pane_id}

      false ->
        case do_split(root, target_id, new_id, direction) do
          {:ok, new_root} -> {:ok, %{layout | root: new_root, pane_ids: [new_id | pane_ids]}}
          {:error, :pane_not_found} -> {:error, :pane_not_found}
        end
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
    {:error, :pane_not_found}
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
  @spec close(%__MODULE__{}, PaneId.t()) :: {:ok, %__MODULE__{}} | {:error, :pane_not_found}
  def close(%__MODULE__{root: root, pane_ids: pane_ids} = layout, pane_id) do
    case Enum.member?(pane_ids, pane_id) do
      false ->
        {:error, :pane_not_found}

      true ->
        case do_close(root, pane_id) do
          {:ok, new_root} ->
            {:ok, %{layout | root: new_root, pane_ids: List.delete(pane_ids, pane_id)}}

          {:error, :pane_not_found} ->
            {:error, :pane_not_found}
        end
    end
  end

  defp do_close(%Pane{id: id}, id) do
    {:ok, nil}
  end

  defp do_close(%Pane{}, _) do
    {:error, :pane_not_found}
  end

  defp do_close(%Node{} = node, pane_id) do
    case do_close(node.left, pane_id) do
      {:ok, nil} ->
        {:ok, node.right}

      {:ok, new_left} ->
        {:ok, %{node | left: new_left}}

      {:error, :pane_not_found} ->
        case do_close(node.right, pane_id) do
          {:ok, nil} ->
            {:ok, node.left}

          {:ok, new_right} ->
            {:ok, %{node | right: new_right}}

          {:error, :pane_not_found} ->
            {:error, :pane_not_found}
        end
    end
  end

  # Swap panes
  @spec swap(%__MODULE__{}, PaneId.t(), PaneId.t()) ::
          {:ok, %__MODULE__{}} | {:error, :pane_not_found} | {:error, :swap_failed}
  def swap(%__MODULE__{root: root, pane_ids: pane_ids} = layout, pane_1_id, pane_2_id) do
    case Enum.member?(pane_ids, pane_1_id) && Enum.member?(pane_ids, pane_2_id) do
      true ->
        case do_swap(root, pane_1_id, pane_2_id) do
          {:ok, swapped_node} -> %{layout | root: swapped_node}
          {:error, :swap_failed} -> {:error, :swap_failed}
        end

      false ->
        {:error, :pane_not_found}
    end
  end

  defp do_swap(
         %Node{
           left: %Pane{id: left_pane_id} = left_pane,
           right: %Pane{id: right_pane_id} = right_pane
         } = original_node,
         left_pane_id,
         right_pane_id
       ),
       do: {:ok, %Node{original_node | right: left_pane, left: right_pane}}

  defp do_swap(
         %Node{
           left: %Pane{},
           right: %Pane{}
         },
         _pane_1_id,
         _pane_2_id
       ) do
    {:error, :swap_failed}
  end

  # resize/3
  def resize(_layout, _target_1, _target_2), do: nil

  # focus/2
  @spec focus(%__MODULE__{}, PaneId.t()) :: {:ok, %__MODULE__{}} | {:error, :pane_not_found}
  def focus(%__MODULE__{pane_ids: pane_ids} = layout, target_id) do
    case Enum.member?(pane_ids, target_id) do
      true -> {:ok, %{layout | focused: target_id}}
      false -> {:error, :pane_not_found}
    end
  end
end
