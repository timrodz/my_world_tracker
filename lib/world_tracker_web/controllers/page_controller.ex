defmodule WorldTrackerWeb.PageController do
  use WorldTrackerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
