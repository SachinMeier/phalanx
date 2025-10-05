defmodule PhalanxWeb.PageController do
  use PhalanxWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
