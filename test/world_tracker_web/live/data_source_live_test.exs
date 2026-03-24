defmodule WorldTrackerWeb.DataSourceLiveTest do
  use WorldTrackerWeb.ConnCase

  import Phoenix.LiveViewTest
  import WorldTracker.SourcesFixtures

  @create_attrs %{name: "some name", slug: "some slug", base_url: "some base_url"}
  @update_attrs %{
    name: "some updated name",
    slug: "some updated slug",
    base_url: "some updated base_url"
  }
  @invalid_attrs %{name: nil, slug: nil, base_url: nil}
  defp create_data_source(_) do
    data_source = data_source_fixture()

    %{data_source: data_source}
  end

  describe "Index" do
    setup [:create_data_source]

    test "lists all data_sources", %{conn: conn, data_source: data_source} do
      {:ok, _index_live, html} = live(conn, ~p"/data-sources")

      assert html =~ "Listing Data Sources"
      assert html =~ data_source.name
    end

    test "saves new data_source", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/data-sources")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Data Source")
               |> render_click()
               |> follow_redirect(conn, ~p"/data-sources/new")

      assert render(form_live) =~ "New Data source"

      assert form_live
             |> form("#data_source-form", data_source: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#data_source-form", data_source: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/data-sources")

      html = render(index_live)
      assert html =~ "Data source created successfully"
      assert html =~ "some name"
    end

    test "updates data_source in listing", %{conn: conn, data_source: data_source} do
      {:ok, index_live, _html} = live(conn, ~p"/data-sources")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#data_sources-#{data_source.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/data-sources/#{data_source}/edit")

      assert render(form_live) =~ "Edit Data source"

      assert form_live
             |> form("#data_source-form", data_source: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#data_source-form", data_source: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/data-sources")

      html = render(index_live)
      assert html =~ "Data source updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes data_source in listing", %{conn: conn, data_source: data_source} do
      {:ok, index_live, _html} = live(conn, ~p"/data-sources")

      assert index_live
             |> element("#data_sources-#{data_source.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#data_sources-#{data_source.id}")
    end
  end

  describe "Show" do
    setup [:create_data_source]

    test "displays data_source", %{conn: conn, data_source: data_source} do
      {:ok, _show_live, html} = live(conn, ~p"/data-sources/#{data_source}")

      assert html =~ data_source.name
      assert html =~ data_source.name
    end

    test "updates data_source and returns to show", %{conn: conn, data_source: data_source} do
      {:ok, show_live, _html} = live(conn, ~p"/data-sources/#{data_source}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/data-sources/#{data_source}/edit?return_to=show")

      assert render(form_live) =~ "Edit Data source"

      assert form_live
             |> form("#data_source-form", data_source: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#data_source-form", data_source: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/data-sources/#{data_source}")

      html = render(show_live)
      assert html =~ "Data source updated successfully"
      assert html =~ "some updated name"
    end
  end
end
