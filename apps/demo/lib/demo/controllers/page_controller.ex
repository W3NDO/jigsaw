defmodule Demo.PageController do
  use Demo, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
