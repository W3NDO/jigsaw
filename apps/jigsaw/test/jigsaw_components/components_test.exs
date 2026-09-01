defmodule JigsawComponents.ComponentsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest
  import JigsawComponents.Components

  alias Bsp.{Layout, Node, Pane}

  describe "layout/1" do
    test "renders and empty layout" do
      layout = %Layout{root: nil}

      html =
        render_component(&layout/1, %{
          jigsaw_layout: layout,
          pane: []
        })

      assert html =~ ~s(class="h-full w-full")
    end

    test "renders a single pane" do
      layout =
        Layout.new(%Pane{id: "terminal"})

      html =
        render_component(&layout/1, %{
          jigsaw_layout: layout,
          pane: [
            %{
              id: "terminal",
              focused: false,
              inner_block: fn _, _ ->
                "Terminal content"
              end
            }
          ]
        })

      assert html =~ ~s(id="terminal")
      assert html =~ "Terminal content"
    end

    test "renders focused pane" do
      layout =
        Layout.new(%Pane{id: "terminal"})

      html =
        render_component(&layout/1, %{
          jigsaw_layout: layout,
          pane: [
            %{
              id: "terminal",
              focused: true,
              inner_block: fn _, _ ->
                "Terminal content"
              end
            }
          ]
        })

      assert html =~ ~s(id="terminal")
      assert html =~ "border-red-500"
      assert html =~ "Terminal content"
    end

    test "renders unfocused pane without focus border" do
      layout =
        Layout.new(%Pane{id: "terminal"})

      html =
        render_component(&layout/1, %{
          jigsaw_layout: layout,
          pane: [
            %{
              id: "terminal",
              focused: false,
              inner_block: fn _, _ ->
                "Terminal content"
              end
            }
          ]
        })

      assert html =~ ~s(id="terminal")
      refute html =~ "border-red-500"
    end

    test "renders a split layout" do
      layout = %Layout{
        root: %Node{
          id: "root-node",
          direction: :horizontal,
          ratio: 0.5,
          left: %Pane{id: "terminal"},
          right: %Pane{id: "about"}
        }
      }

      html =
        render_component(&layout/1, %{
          jigsaw_layout: layout,
          pane: [
            %{
              id: "terminal",
              focused: false,
              inner_block: fn _, _ ->
                "Terminal content"
              end
            },
            %{
              id: "about",
              focused: false,
              inner_block: fn _, _ ->
                "About content"
              end
            }
          ]
        })

      assert html =~ ~s(id="terminal")
      assert html =~ ~s(id="about")

      assert html =~ "Terminal content"
      assert html =~ "About content"
    end

    test "renders vertically split layout" do
      layout = %Layout{
        root: %Node{
          id: "root-node",
          direction: :vertical,
          ratio: 0.5,
          left: %Pane{id: "terminal"},
          right: %Pane{id: "about"}
        }
      }

      html =
        render_component(&layout/1, %{
          jigsaw_layout: layout,
          pane: [
            %{
              id: "terminal",
              focused: false,
              inner_block: fn _, _ ->
                "Terminal content"
              end
            },
            %{
              id: "about",
              focused: false,
              inner_block: fn _, _ ->
                "About content"
              end
            }
          ]
        })

      assert html =~ "flex-col"
      assert html =~ "Terminal content"
      assert html =~ "About content"
    end
  end
end
