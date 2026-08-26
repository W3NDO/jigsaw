defmodule Bsp.LayoutTest do
  use ExUnit.Case
  alias Bsp.{Layout, Node, Pane}

  describe "Generating a new layout" do
    test "creating a valid layout" do
      assert %Bsp.Layout{root: %Bsp.Pane{id: "root"}, focused: "root", pane_ids: ["root"]} ==
               Layout.new(%Pane{id: "root"})
    end

    test "creating an invalid layout" do
      assert Layout.new(%{}) == {:error, :invalid_layout}
    end
  end

  describe "Spliting panes of a layout" do
    setup do
      layout = %Bsp.Layout{root: %Bsp.Pane{id: "root"}, focused: "root", pane_ids: ["root"]}

      %{layout: layout}
    end

    test "split returns left and right panes", %{layout: layout} do
      {:ok, new_layout} = Layout.split(layout, "root", "left", :horizontal)

      assert %Bsp.Layout{
               root: %Bsp.Node{
                 id: _,
                 direction: :horizontal,
                 ratio: 0.5,
                 left: %Bsp.Pane{id: "root"},
                 right: %Bsp.Pane{id: "left"}
               },
               focused: "root",
               pane_ids: ["left", "root"]
             } = new_layout
    end

    test "split updates pane_ids", %{layout: layout} do
      {:ok, new_layout} = Layout.split(layout, "root", "right", :horizontal)

      assert "right" in new_layout.pane_ids
      assert "root" in new_layout.pane_ids
    end

    test "split fails with duplicate pane_ids", %{layout: layout} do
      assert {:error, :duplicate_pane_id} == Layout.split(layout, "root", "root", :horizontal)
    end

    test "split fails with pnae_not_found", %{layout: layout} do
      assert {:error, :pane_not_found} ==
               Layout.split(layout, "false_root", "pane_2", :horizontal)
    end
  end

  describe "close a split pane" do
    setup do
      {:ok, layout} =
        %Bsp.Layout{root: %Bsp.Pane{id: "root"}, focused: "root", pane_ids: ["root"]}
        |> Layout.split("root", "right", :vertical)

      %{layout: layout}
    end

    test "close fails with pane_not_found if pane_id doesn't exist ", %{layout: layout} do
      assert {:error, :pane_not_found} = Layout.close(layout, "non_existent_pane")
    end

    test "Returns a new layout, with pane deleted", %{layout: layout} do
      {:ok, new_layout} = Layout.close(layout, "right")

      assert %Bsp.Layout{root: %Bsp.Pane{id: "root"}, focused: "root", pane_ids: ["root"]} ==
               new_layout
    end
  end

  describe "Swapping panes" do
    setup do
      {:ok, layout} =
        %Bsp.Layout{root: %Bsp.Pane{id: "root"}, focused: "root", pane_ids: ["root"]}
        |> Layout.split("root", "right", :vertical)

      %{layout: layout}
    end

    test "fails with pane_not_found if pane_id doesnt exist", %{layout: layout} do
      assert {:error, :pane_not_found} = Layout.swap(layout, "root", "non_existent_pane")
    end

    test "swaps panes", %{layout: layout} do
      assert %Bsp.Layout{
               focused: "root",
               pane_ids: ["right", "root"],
               root: %Bsp.Node{
                 direction: :vertical,
                 left: %Bsp.Pane{id: "right"},
                 ratio: 0.5,
                 right: %Bsp.Pane{id: "root"}
               }
             } = Layout.swap(layout, "root", "right")
    end
  end

  describe "swap focus" do
    setup do
      {:ok, layout} =
        %Bsp.Layout{root: %Bsp.Pane{id: "root"}, focused: "root", pane_ids: ["root"]}
        |> Layout.split("root", "right", :vertical)

      %{layout: layout}
    end

    test "fails with pane_not_found", %{layout: layout} do
      assert {:error, :pane_not_found} = Layout.focus(layout, "non_existent_pane")
    end

    test "updates focused pane", %{layout: layout} do
      {:ok, updated_layout} = Layout.focus(layout, "right")
      assert updated_layout.focused == "right"
    end
  end

  describe "Query: Panes" do
    setup do
      {:ok, layout} =
        %Bsp.Layout{root: %Bsp.Pane{id: "root"}, focused: "root", pane_ids: ["root"]}
        |> Layout.split("root", "right", :vertical)

      %{layout: layout}
    end

    test "Get all the panes in the layout", %{layout: layout} do
      assert Layout.panes(layout) == ["right", "root"]
    end
  end

  describe "Query: find" do
    setup do
      {:ok, layout} =
        %Bsp.Layout{root: %Bsp.Pane{id: "root"}, focused: "root", pane_ids: ["root"]}
        |> Layout.split("root", "right", :vertical)

      %{layout: layout}
    end

    test "Fails with pane_not_found if pane doesn't exist", %{layout: layout} do
      assert {:error, :pane_not_found} = Layout.find(layout, "left2")
    end

    test "Returns the pane if it exists", %{layout: layout} do
      assert {:ok, %Pane{id: "right"}} = Layout.find(layout, "right")
    end
  end

  describe "Query: focused?" do
    setup do
      {:ok, layout} =
        %Bsp.Layout{root: %Bsp.Pane{id: "root"}, focused: "root", pane_ids: ["root"]}
        |> Layout.split("root", "right", :vertical)

      %{layout: layout}
    end

    test "Fails with pane_not_found if pane doesn't exist", %{layout: layout} do
      assert {:error, :pane_not_found} = Layout.focused?(layout, "left2")
    end

    test "Returns true if the pane exists and is focused", %{layout: layout} do
      assert true == Layout.focused?(layout, "root")
    end

    test "Returns false if the pane exists and is not focused", %{layout: layout} do
      assert false == Layout.focused?(layout, "right")
    end
  end

  describe "Query: focused" do
    setup do
      {:ok, layout} =
        %Bsp.Layout{root: %Bsp.Pane{id: "root"}, focused: "root", pane_ids: ["root"]}
        |> Layout.split("root", "right", :vertical)

      %{layout: layout}
    end

    test "Returns the focused pane_id", %{layout: layout} do
      assert {:ok, "root"} = Layout.focused(layout)
    end
  end

  describe "Query: Parent" do
    setup do
      {:ok, layout} =
        %Bsp.Layout{root: %Bsp.Pane{id: "root"}, focused: "root", pane_ids: ["root"]}
        |> Layout.split("root", "right", :vertical)

      {:ok, layout} = Layout.split(layout, "right", "left", :horizontal)

      %{layout: layout}
    end

    test "fails with pane_not_found if the pane_id doesn't exist", %{layout: layout} do
      assert {:error, :pane_not_found} == Layout.parent(layout, "non_existent_id")
    end

    test "Returns the parent node of a pane", %{layout: layout} do
      assert {:ok, %Node{}} = Layout.parent(layout, "right")
    end
  end

  describe "Query: Children" do
    setup do
      {:ok, layout} =
        %Bsp.Layout{root: %Bsp.Pane{id: "root"}, focused: "root", pane_ids: ["root"]}
        |> Layout.split("root", "right", :vertical)

      {:ok, layout} = Layout.split(layout, "right", "left", :horizontal)

      %{layout: layout}
    end

    test "fails with node_not_found if the pane_id doesn't exist", %{layout: layout} do
      assert {:error, :node_not_found} == Layout.children(layout, "non_existent_id")
    end

    test "Returns the children of a node. Ensures only 2 children exist", %{layout: layout} do
      node_id = layout.root.id
      assert {:ok, children} = Layout.children(layout, node_id)
      assert length(children) == 2
    end
  end
end
