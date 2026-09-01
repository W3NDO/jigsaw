defmodule Bsp.Layout do
  @moduledoc """
  	This module allows for manipulation of the layout tree.
  """

  alias Bsp.{Node, Pane}
  alias Types.{Id, ValidationError}

  defstruct root: nil, focused: nil, pane_ids: []

  @type t :: %{root: tree(), focused: String.t(), pane_ids: list(String.t())}

  @type tree :: Pane.t() | Node.t()

  @doc """
  Creates a new empty layout
  """
  @spec new :: %__MODULE__{}
  def new, do: %__MODULE__{}

  @doc """
  Creates a new Layout with a single pane
  """
  @spec new(Pane.t()) :: %__MODULE__{}
  def new(%Pane{id: root_name} = root_pane) do
    %__MODULE__{
      root: root_pane,
      focused: root_name,
      pane_ids: [root_name]
    }
  end

  def new(_), do: {:error, :invalid_layout}

  @doc """
  Takes an empty layout and a pane and returns the layout with the pane.

  ## Examples

      iex> Bsp.Layout.insert(%Bsp.Layout{root: nil, focused: nil, pane_ids: []}, %Bsp.Pane{id: "temp"})
      %Bsp.Layout{root: %Bsp.Pane{id: "temp"}, focused: "temp", pane_ids: ["temp"]}
  """
  @spec insert(__MODULE__.t(), Pane.t()) :: __MODULE__.t() | {:error, :invalid_layout}
  def insert(%__MODULE__{pane_ids: pane_ids} = layout, %Pane{id: id} = pane) do
    %{layout | root: pane, focused: id, pane_ids: [id | pane_ids]}
  end

  def insert(_, %Node{}), do: {:error, :invalid_layout}

  @doc """
  Takes in a layout, a pane ID and a new pane ID to split it with. Returns an updated layout with the specified pane split into a node with 2 panes.
  """
  @spec split(%__MODULE__{}, Id.t(), Id.t()) ::
          {:ok, %__MODULE__{}} | {:error, :pane_not_found} | {:error, :duplicate_pane_id}

  def split(%__MODULE__{root: nil} = layout, _, new_id) do
    {:ok, insert(layout, %Pane{id: new_id})}
  end

  def split(
        %__MODULE__{root: %Pane{}},
        target_id,
        target_id
      ) do
    {:error, :duplicate_pane_id}
  end

  def split(
        %__MODULE__{root: %Pane{id: target_id} = pane, pane_ids: [target_id] = pane_ids} = layout,
        target_id,
        new_id
      ) do
    new_root = %Node{
      id: Id.gen_id(),
      direction: :horizontal,
      ratio: 0.5,
      left: pane,
      right: %Pane{id: new_id}
    }

    {:ok, %{layout | root: new_root, focused: new_id, pane_ids: [new_id | pane_ids]}}
  end

  def split(
        %__MODULE__{root: %Pane{id: target_id}, pane_ids: [target_id]},
        _non_existent_id,
        _new_id
      ) do
    {:error, :pane_not_found}
  end

  def split(
        %__MODULE__{root: %Node{} = root, pane_ids: pane_ids} = layout,
        target_id,
        new_id
      ) do
    case not Enum.member?(pane_ids, target_id) do
      true ->
        {:error, :pane_not_found}

      false ->
        case do_split(root, target_id, new_id) do
          {:ok, new_root} ->
            {:ok, %{layout | focused: new_id, root: new_root, pane_ids: [new_id | pane_ids]}}

          {:error, :pane_not_found} ->
            {:error, :pane_not_found}
        end
    end
  end

  # Found the pane to split
  defp do_split(%Pane{id: id} = pane, id, new_id, direction) do
    new_direction =
      case direction do
        :horizontal -> :vertical
        :vertical -> :horizontal
      end

    {:ok,
     %Node{
       id: Id.gen_id(),
       direction: new_direction,
       ratio: 0.5,
       left: pane,
       right: %Pane{id: new_id}
     }}
  end

  # Wrong pane
  defp do_split(%Pane{}, _, _, _) do
    {:error, :pane_not_found}
  end

  # # Search the left first
  defp do_split(
         %Node{left: %Pane{} = left_pane, right: %Pane{} = right_pane, direction: direction} =
           split,
         target_id,
         new_id
       ) do
    case do_split(left_pane, target_id, new_id, direction) do
      {:ok, new_left} ->
        {:ok, %{split | left: new_left}}

      {:error, :pane_not_found} ->
        case do_split(right_pane, target_id, new_id, direction) do
          {:ok, new_right} ->
            {:ok, %{split | right: new_right}}

          {:error, :pane_not_found} ->
            {:error, :pane_not_found}
        end
    end
  end

  defp do_split(
         %Node{left: %Node{} = left_node, right: %Node{} = right_node} =
           split,
         target_id,
         new_id
       ) do
    case do_split(left_node, target_id, new_id) do
      {:ok, new_left} ->
        {:ok, %{split | left: new_left}}

      {:error, :pane_not_found} ->
        case do_split(right_node, target_id, new_id) do
          {:ok, new_right} -> {:ok, %{split | right: new_right}}
          {:error, :pane_not_found} -> {:error, :pane_not_found}
        end
    end
  end

  defp do_split(
         %Node{left: %Node{} = left_node, right: %Pane{} = right_pane, direction: direction} =
           split,
         target_id,
         new_id
       ) do
    case do_split(left_node, target_id, new_id) do
      {:ok, new_left} ->
        {:ok, %{split | left: new_left}}

      {:error, :pane_not_found} ->
        case do_split(right_pane, target_id, new_id, direction) do
          {:ok, new_right} -> {:ok, %{split | right: new_right}}
          {:error, :pane_not_found} -> {:error, :pane_not_found}
        end
    end
  end

  defp do_split(
         %Node{right: %Node{} = right_node, left: %Pane{} = left_pane, direction: direction} =
           split,
         target_id,
         new_id
       ) do
    case do_split(right_node, target_id, new_id) do
      {:ok, new_right} ->
        {:ok, %{split | right: new_right}}

      {:error, :pane_not_found} ->
        case do_split(left_pane, target_id, new_id, direction) do
          {:ok, new_left} -> {:ok, %{split | left: new_left}}
          {:error, :pane_not_found} -> {:error, :pane_not_found}
        end
    end
  end

  @doc """
  Takes in a layout and a `pane_id` to close. Returns a new layout with the pane with the specified `pane_id` removed from the tree.
  """
  @spec close(%__MODULE__{}, Id.t()) :: {:ok, %__MODULE__{}} | {:error, :pane_not_found}
  def close(%__MODULE__{root: root, pane_ids: pane_ids} = layout, pane_id) do
    case Enum.member?(pane_ids, pane_id) do
      false ->
        {:error, :pane_not_found}

      true ->
        pane_ids = List.delete(pane_ids, pane_id)
        new_focused = if Enum.empty?(pane_ids), do: nil, else: Enum.random(pane_ids)

        case do_close(root, pane_id) do
          {:ok, new_root} ->
            {:ok, %{layout | root: new_root, focused: new_focused, pane_ids: pane_ids}}

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

  @doc """
  Swaps the positions of panes. For now you can only swap panes on the same node.
  """
  @spec swap(%__MODULE__{}, Id.t(), Id.t()) ::
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
         %Node{},
         _pane_1_id,
         _pane_2_id
       ) do
    {:error, :swap_failed}
  end

  # focus/2
  @spec focus(%__MODULE__{}, Id.t()) :: {:ok, %__MODULE__{}} | {:error, :pane_not_found}
  def focus(%__MODULE__{pane_ids: pane_ids} = layout, target_id) do
    case Enum.member?(pane_ids, target_id) do
      true -> {:ok, %{layout | focused: target_id}}
      false -> {:error, :pane_not_found}
    end
  end

  # ============== LAYOUT QUERIES =====================
  # Layout.panes/1
  # Layout.find/2
  # Layout.focused/1
  # Layout.parent/2
  # Layout.children/2
  # Layout.validate/1

  @doc """
  Returns a list of pane_ids that exist in the layout tree
  """
  @spec panes(%__MODULE__{}) :: list(Id.t())
  def panes(%__MODULE__{pane_ids: pane_ids}), do: pane_ids

  @doc """
  Finds a pane with the specified `pane_id` in the tree. Returns a pane struct or `{:error, :pane_not_found}`
  """
  @spec find(%__MODULE__{}, Id.t()) :: Pane.t() | {:error, :pane_not_found}
  def find(%__MODULE__{root: layout_node, pane_ids: pane_ids}, pane_id) do
    case Enum.member?(pane_ids, pane_id) do
      true ->
        find_pane(layout_node, pane_id)

      false ->
        {:error, :pane_not_found}
    end
  end

  defp find_pane(
         %Node{
           left: %Pane{id: pane_id} = left_pane
         },
         pane_id
       ) do
    {:ok, left_pane}
  end

  defp find_pane(
         %Node{
           right: %Pane{id: pane_id} = right_pane
         },
         pane_id
       ) do
    {:ok, right_pane}
  end

  defp find_pane(
         %Node{
           left: %Node{} = left_node,
           right: %Node{} = right_node
         },
         pane_id
       ) do
    case find_pane(left_node, pane_id) do
      {:error, :pane_not_found} -> find_pane(right_node, pane_id)
      {:ok, pane} -> {:ok, pane}
    end
  end

  defp find_pane(
         %Node{},
         _pane_id
       ) do
    {:error, :pane_not_found}
  end

  @doc """
  Queries whether a pane is in focus or not. Returns a boolean or `{:error, :pane_not_found}` if the `pane_id` doesn't exist
  """
  @spec focused?(%__MODULE__{}, Id.t()) :: boolean()
  def focused?(%__MODULE__{focused: focused, pane_ids: pane_ids}, pane_id) do
    case Enum.member?(pane_ids, pane_id) do
      true ->
        pane_id == focused

      false ->
        {:error, :pane_not_found}
    end
  end

  @doc """
  Returns `{:ok, pane_id}` with `pane_id` being the id of the pane in focus. Could also return nil if there are no panes.
  """
  @spec focused(%__MODULE__{}) :: {:ok, Id.t()}
  def focused(%__MODULE__{focused: focused}) do
    {:ok, focused}
  end

  @doc """
  Returns `pane_id` in focus or nil.
  """
  @spec focused!(%__MODULE__{}) :: Id.t()
  def focused!(%__MODULE__{focused: focused}) do
    focused
  end

  @doc """
  Returns a Node struct, or {:error, :pane_not_found} or {:error, :no_parent}.
  """
  @spec parent(%__MODULE__{}, Id.t()) ::
          {:ok, Node.t()} | {:error, :pane_not_found} | {:error, :no_parent}
  def parent(%__MODULE__{root: root_node, pane_ids: pane_ids}, pane_id) do
    case Enum.member?(pane_ids, pane_id) do
      true -> find_parent(root_node, pane_id)
      false -> {:error, :pane_not_found}
    end
  end

  defp find_parent(%Node{right: %Pane{id: pane_id}} = node, pane_id) do
    {:ok, node}
  end

  defp find_parent(%Node{left: %Pane{id: pane_id}} = node, pane_id) do
    {:ok, node}
  end

  defp find_parent(%Node{right: %Node{} = right_node, left: %Pane{}}, pane_id) do
    case find_parent(right_node, pane_id) do
      {:ok, node} -> {:ok, node}
      {:error, :no_parent} -> {:error, :node_not_found}
    end
  end

  defp find_parent(%Node{left: %Node{} = left_node, right: %Pane{}}, pane_id) do
    case find_parent(left_node, pane_id) do
      {:ok, node} -> {:ok, node}
      {:error, :no_parent} -> {:error, :node_not_found}
    end
  end

  defp find_parent(%Node{right: %Node{} = right_node, left: %Node{} = left_node}, pane_id) do
    case find_parent(left_node, pane_id) do
      {:ok, node} -> {:ok, node}
      {:error, :no_parent} -> find_parent(right_node, pane_id)
    end
  end

  defp find_parent(_, _pane_id) do
    {:error, :no_parent}
  end

  @doc """
  Returns a Node struct, or {:error, :node_not_found} or {:error, :no_children}.
  """
  @spec children(%__MODULE__{}, String.t()) ::
          {:ok, list(Pane.t())} | {:error, :node_not_found} | {:error, :no_children}
  def children(%__MODULE__{root: root_node}, node_id) do
    find_children(root_node, node_id)
  end

  defp find_children(
         %Node{id: node_id, left: left_child, right: right_child},
         node_id
       ) do
    {:ok, [left_child, right_child]}
  end

  defp find_children(%Node{left: %Node{} = left_child, right: %Pane{}}, node_id) do
    case find_children(left_child, node_id) do
      {:ok, children} -> {:ok, children}
      {:error, :no_children_found} -> {:error, :no_children_found}
    end
  end

  defp find_children(%Node{right: %Node{} = right_child, left: %Pane{}}, node_id) do
    case find_children(right_child, node_id) do
      {:ok, children} -> {:ok, children}
      {:error, :no_children_found} -> {:error, :no_children_found}
    end
  end

  defp find_children(
         %Node{left: %Node{} = left_child, right: %Node{} = right_child},
         node_id
       ) do
    case find_children(left_child, node_id) do
      {:ok, children} -> {:ok, children}
      {:error, :no_children_found} -> find_children(right_child, node_id)
    end
  end

  defp find_children(%Node{}, _) do
    {:error, :no_children_found}
  end

  @doc """
  Validates the layout based on specified invariants on nodes, panes and other crucial elements
  """
  @spec validate(%__MODULE__{}) :: {:ok, :valid} | {:error, :invalid}
  def validate(%__MODULE__{root: %Node{} = root_node}) do
    do_validate(root_node)
  end

  defp do_validate(
         %Node{
           id: node_id,
           left: %Node{id: left_child_id} = left_child,
           right: %Node{id: right_child_id} = right_child
         } = node
       ) do
    with {:ok, :valid} <- validate_node(node),
         {:ok, :valid} <- do_validate(left_child),
         {:ok, :valid} <- do_validate(right_child) do
      {:ok, :valid}
    else
      {:error, %ValidationError{id: ^node_id} = error} -> {:error, error}
      {:error, %ValidationError{id: ^left_child_id} = error} -> {:error, error}
      {:error, %ValidationError{id: ^right_child_id} = error} -> {:error, error}
    end
  end

  defp do_validate(
         %Node{
           id: node_id,
           left: %Pane{id: left_child_id} = left_child,
           right: %Pane{id: right_child_id} = right_child
         } = node
       ) do
    with {:ok, :valid} <- validate_node(node),
         {:ok, :valid} <- do_validate(left_child),
         {:ok, :valid} <- do_validate(right_child) do
      {:ok, :valid}
    else
      {:error, %ValidationError{id: ^node_id} = error} -> {:error, error}
      {:error, %ValidationError{id: ^left_child_id} = error} -> {:error, error}
      {:error, %ValidationError{id: ^right_child_id} = error} -> {:error, error}
    end
  end

  defp do_validate(
         %Node{
           id: node_id,
           left: %Node{id: left_child_id} = left_child,
           right: %Pane{id: right_child_id} = right_child
         } = node
       ) do
    with {:ok, :valid} <- validate_node(node),
         {:ok, :valid} <- do_validate(left_child),
         {:ok, :valid} <- do_validate(right_child) do
      {:ok, :valid}
    else
      {:error, %ValidationError{id: ^node_id} = error} -> {:error, error}
      {:error, %ValidationError{id: ^left_child_id} = error} -> {:error, error}
      {:error, %ValidationError{id: ^right_child_id} = error} -> {:error, error}
    end
  end

  defp do_validate(
         %Node{
           id: node_id,
           left: %Pane{id: left_child_id} = left_child,
           right: %Node{id: right_child_id} = right_child
         } = node
       ) do
    with {:ok, :valid} <- validate_node(node),
         {:ok, :valid} <- do_validate(left_child),
         {:ok, :valid} <- do_validate(right_child) do
      {:ok, :valid}
    else
      {:error, %ValidationError{id: ^node_id} = error} -> {:error, error}
      {:error, %ValidationError{id: ^left_child_id} = error} -> {:error, error}
      {:error, %ValidationError{id: ^right_child_id} = error} -> {:error, error}
    end
  end

  defp do_validate(%Pane{id: _id}) do
    {:ok, :valid}
  end

  # Validates a node
  def validate_node(%Node{id: id, ratio: ratio, direction: direction}) do
    ratio_invariant = 0 < ratio && ratio < 1
    direction_invariant = Enum.member?([:horizontal, :vertical], direction)

    case ratio_invariant && direction_invariant do
      true ->
        {:ok, :valid}

      false ->
        reason =
          cond do
            not ratio_invariant and not direction_invariant ->
              :ratio_and_direction_invariant

            not ratio_invariant ->
              :ratio_invariant

            not direction_invariant ->
              :direction_invariant
          end

        {:error,
         %ValidationError{
           subject: :node,
           id: id,
           validation: :node,
           reason: reason
         }}
    end
  end

  def validate_node(_), do: false
end
