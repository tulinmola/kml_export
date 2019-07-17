defmodule Kml.Csv do
  alias Kml.Folder

  NimbleCSV.define(FolderParser, separator: "\t", escape: "\"")

  @type folder :: Folder.t()

  @spec convert(folder) :: [any]
  def convert(folder) do
    names = get_names(folder.placemarks)
    content = Enum.map(folder.placemarks, &get_row(names, &1))

    FolderParser.dump_to_iodata([names] ++ content)
  end

  defp get_names(placemarks) do
    placemarks
    |> Enum.reduce(%{}, fn placemark, result ->
      names = Enum.map(placemark.data, fn {name, _value} -> {name, true} end)
      Map.merge(result, Map.new(names))
    end)
    |> Map.keys()
  end

  defp get_row(names, placemark) do
    Enum.map(names, fn name ->
      placemark.data
      |> Map.new()
      |> Map.get(name, nil)
    end)
  end
end
