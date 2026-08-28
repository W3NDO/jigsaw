defmodule Bsp.HTmlGeneratorTest do
  use ExUnit.Case, async: true

  alias Bsp.{HtmlGenerator, Layout, Pane}

  describe "Building HTML for a layout" do
    setup do
      %{layout: Layout.new(%Pane{id: "root"})}
    end

    test "generating the html for a layout with one pane.", %{layout: layout} do
      expected_html = """
      <div class="w-full flex">
        <div id="root" class="flex-1"> </div>
      </div>
      """

      assert parse_html(expected_html) == parse_html(HtmlGenerator.generate(layout))
    end

    test "generating the html for a layout with 2 panes and one node", %{layout: layout} do
      {:ok, split_layout} = Layout.split(layout, "root", "right")
      node_id = split_layout.root.id

      expected_html = """
      <div class="w-full flex">
        <div id="#{node_id}" class="flex ">
          <div id="root" class="flex-1"> </div>
          <div id="right" class="flex-1"> </div>
        </div>
      </div>
      """

      assert parse_html(HtmlGenerator.generate(split_layout)) == parse_html(expected_html)
    end

    test "generating the html for a layout with 3 panes and 2 nodes. Split left child", %{
      layout: layout
    } do
      {:ok, split_layout} = Layout.split(layout, "root", "right")
      {:ok, split_layout_2} = Layout.split(split_layout, "root", "left")
      node_id = split_layout.root.id
      {:ok, node_2} = Layout.parent(split_layout_2, "left")
      node_2_id = node_2.id

      expected_html = """
      <div class="w-full flex">
        <div id="#{node_id}" class="flex ">
          <div id="#{node_2_id}" class="flex flex-col">
            <div id="root" class="flex-1"> </div>
            <div id="left" class="flex-1"> </div>
          </div>
          <div id="right" class="flex-1"> </div>
        </div>
      </div>
      """

      assert parse_html(HtmlGenerator.generate(split_layout_2)) == parse_html(expected_html)
    end

    test "generating the html for a layout with 3 panes and 2 nodes. Split Right child", %{
      layout: layout
    } do
      {:ok, split_layout} = Layout.split(layout, "root", "right")
      {:ok, split_layout_2} = Layout.split(split_layout, "right", "left")
      node_id = split_layout.root.id
      {:ok, node_2} = Layout.parent(split_layout_2, "left")
      node_2_id = node_2.id

      expected_html = """
      <div class="w-full flex">
        <div id="#{node_id}" class="flex ">
          <div id="root" class="flex-1"> </div>
          <div id="#{node_2_id}" class="flex flex-col">
            <div id="right" class="flex-1"> </div>
            <div id="left" class="flex-1"> </div>
          </div>
        </div>
      </div>
      """

      assert parse_html(HtmlGenerator.generate(split_layout_2)) == parse_html(expected_html)
    end

    test "generating the html for a layout with 4 panes and 2 nodes. Split both children", %{
      layout: layout
    } do
      {:ok, split_layout} = Layout.split(layout, "root", "right")
      {:ok, split_layout_2} = Layout.split(split_layout, "right", "left")
      {:ok, split_layout_3} = Layout.split(split_layout_2, "root", "branch")
      node_id = split_layout.root.id

      {:ok, node_2} = Layout.parent(split_layout_3, "left")
      {:ok, node_3} = Layout.parent(split_layout_3, "branch")

      node_2_id = node_2.id
      node_3_id = node_3.id

      expected_html = """
      <div class="w-full flex">
        <div id="#{node_id}" class="flex ">
          <div id="#{node_3_id}" class="flex flex-col">
            <div id="root" class="flex-1"> </div>
            <div id="branch" class="flex-1"> </div>
          </div>
          <div id="#{node_2_id}" class="flex flex-col">
            <div id="right" class="flex-1"> </div>
            <div id="left" class="flex-1"> </div>
          </div>
        </div>
      </div>
      """

      assert parse_html(HtmlGenerator.generate(split_layout_3)) == parse_html(expected_html)
    end
  end

  defp parse_html(html) do
    Floki.parse_document!(html)
  end
end
