defmodule Bsp.HtmlGenerator do
  @moduledoc """
  This module will take in a layout and generate the appropriate HTML for it.
  """
  alias Bsp.{Layout, Node, Pane}

  def generate(%Layout{root: %Pane{} = pane}) do
    case do_generate(pane) do
      {:ok, generated_pane_html} ->
        """
        <div class="w-full flex">
          #{generated_pane_html}</div>
        """

      _ ->
        """
        <div> No Pane was defined </div>
        """
    end
  end

  def generate(%Layout{root: %Node{} = node}) do
    case do_generate(node) do
      {:ok, generated_pane_html} ->
        """
        <div class="w-full flex">
          #{generated_pane_html}</div>
        """

      _ ->
        """
        <div> No Pane was defined </div>
        """
    end
  end

  defp do_generate(%Node{
         id: node_id,
         left: %Pane{} = left_pane,
         right: %Pane{} = right_pane,
         direction: direction
       }) do
    {:ok, right_pane_html} = do_generate(right_pane)
    {:ok, left_pane_html} = do_generate(left_pane)

    flex_direction =
      case direction do
        :vertical -> "flex-col"
        :horizontal -> ""
      end

    {:ok,
     """
     <div id="#{node_id}" class="flex #{flex_direction}">
       #{left_pane_html}
       #{right_pane_html}
     </div>
     """}
  end

  defp do_generate(%Node{
         id: node_id,
         left: %Node{} = left_node,
         right: %Pane{} = right_pane,
         direction: direction
       }) do
    {:ok, right_pane_html} = do_generate(right_pane)
    {:ok, left_node_html} = do_generate(left_node)

    flex_direction =
      case direction do
        :vertical -> "flex-col"
        :horizontal -> ""
      end

    {:ok,
     """
     <div id="#{node_id}" class="flex #{flex_direction}">
       #{left_node_html}
       #{right_pane_html}
     </div>
     """}
  end

  defp do_generate(%Node{
         id: node_id,
         right: %Node{} = right_node,
         left: %Pane{} = left_pane,
         direction: direction
       }) do
    {:ok, right_node_html} = do_generate(right_node)
    {:ok, left_pane_html} = do_generate(left_pane)

    flex_direction =
      case direction do
        :vertical -> "flex-col"
        :horizontal -> ""
      end

    {:ok,
     """
     <div id="#{node_id}" class="flex #{flex_direction}">
       #{left_pane_html}
       #{right_node_html}
     </div>
     """}
  end

  defp do_generate(%Node{
         id: node_id,
         right: %Node{} = right_node,
         left: %Node{} = left_node,
         direction: direction
       }) do
    {:ok, right_node_html} = do_generate(right_node)
    {:ok, left_node_html} = do_generate(left_node)

    flex_direction =
      case direction do
        :vertical -> "flex-col"
        :horizontal -> ""
      end

    {:ok,
     """
     <div id="#{node_id}" class="flex #{flex_direction}">
       #{left_node_html}
       #{right_node_html}
     </div>
     """}
  end

  defp do_generate(%Pane{id: id}) do
    {:ok,
     """
     <div id="#{id}" class="flex-1"> </div>
     """}
  end
end
