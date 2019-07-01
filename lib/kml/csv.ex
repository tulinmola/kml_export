defmodule Kml.Csv do
  alias Kml.Folder

  NimbleCSV.define(FolderParser, separator: "\t", escape: "\"")

  @type folder :: Folder.t()

  @spec convert(folder) :: [any]
  def convert(folder) do
    first = Enum.at(folder.placemarks, 0)
    header = [get_names(first.data)]
    content = Enum.map(folder.placemarks, &get_row/1)

    FolderParser.dump_to_iodata(header ++ content)
  end

  defp get_names(data) do
    Enum.map(data, fn {name, _value} -> name end)
  end

  defp get_row(placemark) do
    Enum.map(placemark.data, &get_value/1)
  end

  defp get_value({_name, nil}), do: ""

  defp get_value({_name, value}), do: value
end
