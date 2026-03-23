defmodule WorldTracker.SourcesTest do
  use WorldTracker.DataCase

  alias WorldTracker.Sources

  describe "data_sources" do
    alias WorldTracker.Sources.DataSource

    import WorldTracker.SourcesFixtures

    @invalid_attrs %{name: nil, slug: nil, base_url: nil}

    test "list_data_sources/0 returns all data_sources" do
      data_source = data_source_fixture()

      assert Enum.any?(Sources.list_data_sources(), fn listed_data_source ->
               listed_data_source.id == data_source.id
             end)
    end

    test "get_data_source!/1 returns the data_source with given id" do
      data_source = data_source_fixture()

      fetched_data_source = Sources.get_data_source!(data_source.id)
      assert fetched_data_source.id == data_source.id
      assert fetched_data_source.slug == data_source.slug
    end

    test "create_data_source/1 with valid data creates a data_source" do
      valid_attrs = %{name: "some name", slug: "some slug", base_url: "some base_url"}

      assert {:ok, %DataSource{} = data_source} = Sources.create_data_source(valid_attrs)
      assert data_source.name == "some name"
      assert data_source.slug == "some slug"
      assert data_source.base_url == "some base_url"
    end

    test "create_data_source/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sources.create_data_source(@invalid_attrs)
    end

    test "update_data_source/2 with valid data updates the data_source" do
      data_source = data_source_fixture()

      update_attrs = %{
        name: "some updated name",
        slug: "some updated slug",
        base_url: "some updated base_url"
      }

      assert {:ok, %DataSource{} = data_source} =
               Sources.update_data_source(data_source, update_attrs)

      assert data_source.name == "some updated name"
      assert data_source.slug == "some updated slug"
      assert data_source.base_url == "some updated base_url"
    end

    test "update_data_source/2 with invalid data returns error changeset" do
      data_source = data_source_fixture()
      assert {:error, %Ecto.Changeset{}} = Sources.update_data_source(data_source, @invalid_attrs)

      fetched_data_source = Sources.get_data_source!(data_source.id)
      assert fetched_data_source.id == data_source.id
      assert fetched_data_source.slug == data_source.slug
    end

    test "delete_data_source/1 deletes the data_source" do
      data_source = data_source_fixture()
      assert {:ok, %DataSource{}} = Sources.delete_data_source(data_source)
      assert_raise Ecto.NoResultsError, fn -> Sources.get_data_source!(data_source.id) end
    end

    test "change_data_source/1 returns a data_source changeset" do
      data_source = data_source_fixture()
      assert %Ecto.Changeset{} = Sources.change_data_source(data_source)
    end
  end
end
