# Jigsaw

---

Jigsaw is a proof of concept for a layout tiling library for Phoenix Liveview. It is inspired by BSP-style desktop tiling layouts such as Hyprland's Dwindle layout, but applies the same model to arbitrary Phoenix LiveView content. The layout is currently generated with a variant the binary space partitioning algorithm. Built with and for Elixir and Phoenix LiveView.

## Layout

The layout uses a Binary tree of sorts to define panes and nodes. For instance, if we were to have 3 panes `terminal`, `stats` and `about` on the layout tree, it conceptually looks like this

```
      root
      /    \
terminal    node
            /    \
          about  stats
  ```

The pane will always be a leaf and the `node` will be an inner node on the tree with 2 children. `root` in this case is also a `Bsp.Node` struct.

The Layout API allows for layout manipulation and layout querying.


## Jigsaw Components

This is the phoenix liveview API. 

```
<JigsawComponents.Components.layout jigsaw_layout={@layout} >
  <:pane id="terminal">
    <MyTerminal />
  </:pane>

  <:pane id="stats">
    <MyStats />
  </:pane>
</JigsawComponents.Components.layout>
```

`@layout` is a valid `Bsp.Layout` struct. The pane slots will be identified by the IDs of the `panes` on `@layout`. The Pane slots can then contain valid Phoenix components or valid HTML.

## Installation

The package can be installed by adding `jigsaw` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:jigsaw, "~> 0.1.0"}
  ]
end
```

Documentation can be found at <https://hexdocs.pm/jigsaw>.
