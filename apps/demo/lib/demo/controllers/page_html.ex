defmodule Demo.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use Demo, :html

  import Jigsaw

  embed_templates "page_html/*"
end
