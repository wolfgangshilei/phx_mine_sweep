defmodule MineSweepWeb.PageController do
  use MineSweepWeb, :controller

  def index(conn, _) do
    redirect(conn, to: "/index.html")
  end
end
