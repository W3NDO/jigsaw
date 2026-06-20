defmodule JigsawTest do
  use ExUnit.Case
  doctest Jigsaw

  test "greets the world" do
    assert Jigsaw.hello() == :world
  end
end
