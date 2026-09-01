defmodule Bsp.LayoutTest do
  use ExUnit.Case
  alias Bsp.{Layout, Node, Pane}
  alias Types.ValidationError

  doctest Bsp.Layout

  describe "Generating a new layout" do
    test "creating an empty layout" do
      assert %Layout{root: nil, pane_ids: [], focused: nil} == Layout.new()
    end

    test "creating a valid layout" do
      assert %Bsp.Layout{
               root: %Bsp.Pane{
                 id: "root"
               },
               focused: "root",
               pane_ids: ["root"]
             } ==
               Layout.new(%Pane{id: "root"})
    end

    test "creating an invalid layout" do
      assert Layout.new(%{}) == {:error, :invalid_layout}
    end
  end

  describe "Updating an empty layout" do
    setup do
      %{empty_layout: Layout.new()}
    end

    test "accepts a pane and updates the layout", %{empty_layout: empty_layout} do
      pane = %Pane{id: "root"}

      assert %Layout{root: _pane, pane_ids: ["root"], focused: "root"} =
               Layout.insert(empty_layout, pane)
    end

    test "errors out if you try and insert a node on an empty layout", %{
      empty_layout: empty_layout
    } do
      node = %Node{id: "node_id", left: %Pane{id: "left"}, right: %Pane{id: "right"}}
      assert {:error, :invalid_layout} = Layout.insert(empty_layout, node)
    end
  end

  describe "Spliting panes of a layout" do
    setup do
      layout = %Bsp.Layout{root: %Bsp.Pane{id: "root"}, focused: "root", pane_ids: ["root"]}

      %{layout: layout}
    end

    test "split returns left and right panes", %{layout: layout} do
      {:ok, new_layout} = Layout.split(layout, "root", "left")

      assert %Bsp.Layout{
               root: %Bsp.Node{
                 id: _,
                 direction: :horizontal,
                 ratio: 0.5,
                 left: %Bsp.Pane{id: "root"},
                 right: %Bsp.Pane{id: "left"}
               },
               focused: "left",
               pane_ids: ["left", "root"]
             } = new_layout
    end

    test "split updates pane_ids", %{layout: layout} do
      {:ok, new_layout} = Layout.split(layout, "root", "right")

      assert "right" in new_layout.pane_ids
      assert "root" in new_layout.pane_ids
    end

    test "split alternates direction", %{layout: layout} do
      {:ok, new_layout_1} = Layout.split(layout, "root", "right")

      assert :horizontal == new_layout_1.root.direction

      {:ok, new_layout_2} = Layout.split(new_layout_1, "right", "left")
      {:ok, %Node{direction: new_direction}} = Layout.parent(new_layout_2, "right")
      assert :vertical == new_direction

      {:ok, new_layout_3} = Layout.split(new_layout_2, "left", "another_left")
      {:ok, %Node{direction: new_direction}} = Layout.parent(new_layout_3, "another_left")
      assert :horizontal == new_direction
    end

    test "split fails with duplicate pane_ids", %{layout: layout} do
      assert {:error, :duplicate_pane_id} == Layout.split(layout, "root", "root")
    end

    test "split fails with pnae_not_found", %{layout: layout} do
      assert {:error, :pane_not_found} ==
               Layout.split(layout, "false_root", "pane_2")
    end
  end

  describe "close a split pane" do
    setup do
      {:ok, layout} =
        %Bsp.Layout{root: %Bsp.Pane{id: "root"}, focused: "root", pane_ids: ["root"]}
        |> Layout.split("root", "right")

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
        |> Layout.split("root", "right")

      %{layout: layout}
    end

    test "fails with pane_not_found if pane_id doesnt exist", %{layout: layout} do
      assert {:error, :pane_not_found} = Layout.swap(layout, "root", "non_existent_pane")
    end

    test "swaps panes", %{layout: layout} do
      assert %Bsp.Layout{
               focused: "right",
               pane_ids: ["right", "root"],
               root: %Bsp.Node{
                 direction: :horizontal,
                 left: %Bsp.Pane{id: "right"},
                 ratio: 0.5,
                 right: %Bsp.Pane{id: "root"}
               }
             } = Layout.swap(layout, "root", "right")
    end

    test "Swaps panes on different nodes fails with :swap_failed_error", %{layout: layout} do
      {:ok, new_layout} = Layout.split(layout, "right", "left")

      assert {:error, :swap_failed} = Layout.swap(new_layout, "root", "left")
    end
  end

  describe "change focus" do
    setup do
      {:ok, layout} =
        %Bsp.Layout{root: %Bsp.Pane{id: "root"}, focused: "root", pane_ids: ["root"]}
        |> Layout.split("root", "right")

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
        |> Layout.split("root", "right")

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
        |> Layout.split("root", "right")

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
        |> Layout.split("root", "right")

      %{layout: layout}
    end

    test "Fails with pane_not_found if pane doesn't exist", %{layout: layout} do
      assert {:error, :pane_not_found} = Layout.focused?(layout, "left2")
    end

    test "Returns true if the pane exists and is focused", %{layout: layout} do
      assert true == Layout.focused?(layout, "right")
    end

    test "Returns false if the pane exists and is not focused", %{layout: layout} do
      assert false == Layout.focused?(layout, "root")
    end
  end

  describe "Query: focused" do
    setup do
      {:ok, layout} =
        %Bsp.Layout{root: %Bsp.Pane{id: "root"}, focused: "root", pane_ids: ["root"]}
        |> Layout.split("root", "right")

      %{layout: layout}
    end

    test "Returns the focused pane_id", %{layout: layout} do
      assert {:ok, "right"} = Layout.focused(layout)
    end
  end

  describe "Query: Parent" do
    setup do
      {:ok, layout} =
        %Bsp.Layout{root: %Bsp.Pane{id: "root"}, focused: "root", pane_ids: ["root"]}
        |> Layout.split("root", "right")

      {:ok, layout} = Layout.split(layout, "right", "left")

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
        |> Layout.split("root", "right")

      {:ok, layout} = Layout.split(layout, "right", "left")

      %{layout: layout}
    end

    test "fails with no_children_found if the pane_id doesn't exist", %{layout: layout} do
      assert {:error, :no_children_found} == Layout.children(layout, "non_existent_id")
    end

    test "Returns the children of a node. Ensures only 2 children exist", %{layout: layout} do
      node_id = layout.root.id
      assert {:ok, children} = Layout.children(layout, node_id)
      assert length(children) == 2
    end
  end

  describe "validate_node/1" do
    test "accepts a valid horizontal node" do
      node = %Node{
        id: "node-1",
        direction: :horizontal,
        ratio: 0.5
      }

      assert {:ok, :valid} = Layout.validate_node(node)
    end

    test "accepts a valid vertical node" do
      node = %Node{
        id: "node-1",
        direction: :vertical,
        ratio: 0.5
      }

      assert {:ok, :valid} = Layout.validate_node(node)
    end

    test "rejects a ratio of zero" do
      node = %Node{
        id: "node-1",
        direction: :horizontal,
        ratio: 0.0
      }

      assert {:error, %ValidationError{} = error} =
               Layout.validate_node(node)

      assert error.subject == :node
      assert error.id == "node-1"
      assert error.reason == :ratio_invariant
    end

    test "rejects a ratio of one" do
      node = %Node{
        id: "node-1",
        direction: :horizontal,
        ratio: 1.0
      }

      assert {:error, %ValidationError{} = error} =
               Layout.validate_node(node)

      assert error.subject == :node
      assert error.id == "node-1"
      assert error.reason == :ratio_invariant
    end

    test "rejects a negative ratio" do
      node = %Node{
        id: "node-1",
        direction: :horizontal,
        ratio: -0.5
      }

      assert {:error, %ValidationError{} = error} =
               Layout.validate_node(node)

      assert error.reason == :ratio_invariant
    end

    test "rejects a ratio greater than one" do
      node = %Node{
        id: "node-1",
        direction: :horizontal,
        ratio: 1.5
      }

      assert {:error, %ValidationError{} = error} =
               Layout.validate_node(node)

      assert error.reason == :ratio_invariant
    end

    test "accepts ratios strictly between zero and one" do
      for ratio <- [0.01, 0.25, 0.5, 0.75, 0.99] do
        node = %Node{
          id: "node-1",
          direction: :horizontal,
          ratio: ratio
        }

        assert {:ok, :valid} = Layout.validate_node(node)
      end
    end

    test "rejects an invalid direction" do
      node = %Node{
        id: "node-1",
        direction: :diagonal,
        ratio: 0.5
      }

      assert {:error, %ValidationError{} = error} =
               Layout.validate_node(node)

      assert error.subject == :node
      assert error.id == "node-1"
      assert error.reason == :direction_invariant
    end

    test "accepts only horizontal and vertical directions" do
      for direction <- [:horizontal, :vertical] do
        node = %Node{
          id: "node-1",
          direction: direction,
          ratio: 0.5
        }

        assert {:ok, :valid} = Layout.validate_node(node)
      end
    end

    test "reports both ratio and direction violations" do
      node = %Node{
        id: "node-1",
        direction: :diagonal,
        ratio: 2.0
      }

      assert {:error, %ValidationError{} = error} =
               Layout.validate_node(node)

      assert error.subject == :node
      assert error.id == "node-1"
      assert error.reason == :ratio_and_direction_invariant
    end
  end

  describe "validate/1" do
    setup do
      left = %Pane{
        id: "left"
      }

      right = %Pane{
        id: "right"
      }

      root = %Node{
        id: "root",
        direction: :horizontal,
        ratio: 0.5,
        left: left,
        right: right
      }

      layout = %Layout{
        root: root
      }

      %{layout: layout, root: root, left: left, right: right}
    end

    test "validates a tree containing two panes", %{layout: layout} do
      assert {:ok, :valid} = Layout.validate(layout)
    end

    test "returns the validation error for an invalid root node", %{layout: layout, root: root} do
      root = %{root | direction: :diagonal}
      layout = %{layout | root: root}

      assert {:error, %ValidationError{} = error} =
               Layout.validate(layout)

      assert error.id == "root"
      assert error.subject == :node
      assert error.reason == :direction_invariant
    end
  end
end
