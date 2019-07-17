defmodule Kml.Parser do
  alias Kml

  import SweetXml

  @type option :: {:place, boolean}
  @type kml :: Kml.t()

  @mapping document: [
             ~x"//Document",
             name: ~x"./name/text()"s,
             folders: [
               ~x"Folder"l,
               name: ~x"./name/text()"s,
               placemarks: [
                 ~x"Placemark"l,
                 name: ~x"./name/text()"s,
                 data: [
                   ~x"ExtendedData/Data"l,
                   name: ~x"@name"s,
                   value: ~x"./value/text()"s
                 ],
                 coordinates: ~x"Point/coordinates/text()"s
               ]
             ]
           ]

  @spec do_parse(binary, [option]) :: kml
  def do_parse(path, opts) do
    request_place? = Keyword.get(opts, :places, false)

    path
    |> File.stream!([{:encoding, :utf8}])
    |> parse()
    |> xmap(@mapping)
    |> parse_document(request_place?)
  end

  defp parse_document(%{document: %{name: name, folders: folders}}, request_place?) do
    %Kml{name: name, folders: Enum.map(folders, &parse_folder(&1, request_place?))}
  end

  defp parse_folder(%{name: name, placemarks: placemarks}, request_place?) do
    %Kml.Folder{
      name: name,
      placemarks: Enum.map(placemarks, &parse_placemark(&1, request_place?))
    }
  end

  defp parse_placemark(%{name: name, data: data, coordinates: coordinates}, true) do
    data_with_place =
      data
      |> parse_placemark_data()
      |> Enum.concat(Kml.Places.request_data(name, coordinates))

    %Kml.Placemark{data: data_with_place}
  end

  defp parse_placemark(%{data: data}, false = _dont_request_place) do
    %Kml.Placemark{data: parse_placemark_data(data)}
  end

  defp parse_placemark_data(data) do
    Enum.map(data, fn %{name: name, value: value} ->
      {name, value}
    end)
  end
end
