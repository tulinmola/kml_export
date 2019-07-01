defmodule Kml.Parser do
  alias Kml

  import SweetXml

  @type kml :: Kml.t()

  @mapping document: [
             ~x"//Document",
             name: ~x"./name/text()",
             folders: [
               ~x"Folder"l,
               name: ~x"./name/text()",
               placemarks: [
                 ~x"Placemark"l,
                 name: ~x"./name/text()",
                 data: [
                   ~x"ExtendedData/Data"l,
                   name: ~x"@name",
                   value: ~x"./value/text()"
                 ]
               ]
             ]
           ]

  @spec do_parse(binary) :: kml
  def do_parse(path) do
    path
    |> File.stream!([{:encoding, :utf8}])
    |> parse()
    |> xmap(@mapping)
    |> parse_document()
  end

  defp parse_document(%{document: %{name: name, folders: folders}}) do
    %Kml{name: name, folders: Enum.map(folders, &parse_folder/1)}
  end

  defp parse_folder(%{name: name, placemarks: placemarks}) do
    %Kml.Folder{name: name, placemarks: Enum.map(placemarks, &parse_placemark/1)}
  end

  defp parse_placemark(%{data: data}) do
    map =
      Enum.map(data, fn %{name: name, value: value} ->
        {name, value}
      end)

    %Kml.Placemark{data: map}
  end
end
