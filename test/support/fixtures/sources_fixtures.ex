defmodule WorldTracker.SourcesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WorldTracker.Sources` context.
  """

  @doc """
  Generate a data_source.
  """
  def data_source_fixture(attrs \\ %{}) do
    {:ok, data_source} =
      attrs
      |> Enum.into(%{
        base_url: "some base_url",
        name: "some name",
        slug: "some-slug-#{System.unique_integer([:positive])}"
      })
      |> WorldTracker.Sources.create_data_source()

    data_source
  end
end
