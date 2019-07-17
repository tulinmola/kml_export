defmodule Kml.Places do
  @gmaps_key Application.get_env(:kml, :gmaps_key)

  @spec request_data(binary, binary | [float]) :: []
  def request_data(name, coordinates) when is_binary(coordinates) do
    coordinates =
      coordinates
      |> String.split(",")
      |> Enum.slice(0..1)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.to_float/1)

    request_data(name, coordinates)
  end

  def request_data(name, coordinates) do
    uri =
      URI.encode(
        "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=#{name}&inputtype=textquery&fields=formatted_address,name,place_id,geometry&key=#{
          @gmaps_key
        }"
      )

    IO.puts("name: \"#{name}\"")
    IO.puts("GET #{uri}")

    case HTTPoison.get(uri) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        parse_find_place_response(name, body, coordinates)

      {:ok, %HTTPoison.Response{status_code: status}} ->
        IO.puts("ERROR #{status}")
        [{"name", name}]

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("ERROR #{reason}")
        [{"name", name}]
    end
  end

  defp parse_find_place_response(name, body, coordinates) do
    body
    |> Jason.decode!()
    |> Map.get("candidates", [])
    |> Enum.min_by(&get_candidate_distance(&1, coordinates), fn -> nil end)
    |> parse_candidate(name)
  end

  defp get_candidate_distance(
         %{
           "geometry" => %{
             "location" => %{"lat" => candidate_latitude, "lng" => candidate_longitude}
           }
         },
         [longitude, latitude]
       ) do
    da = candidate_latitude - latitude
    db = candidate_longitude - longitude
    da * da + db * db
  end

  defp get_candidate_distance(%{"name" => name}, _coordinates) do
    IO.puts("ERROR couldn't get distance to candidate: \"#{name}\"")

    1
  end

  defp parse_candidate(%{"place_id" => place_id}, name) do
    uri =
      "https://maps.googleapis.com/maps/api/place/details/json?placeid=#{place_id}&fields=name,formatted_phone_number,formatted_address,website,geometry&key=#{
        @gmaps_key
      }"

    IO.puts("place_id: \"#{place_id}\"")
    IO.puts("GET #{uri}")

    case HTTPoison.get(uri) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        parse_place_response(body)

      {:ok, %HTTPoison.Response{status_code: status}} ->
        IO.puts("ERROR #{status}")
        [{"name", name}, {"place_id", place_id}]

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("ERROR #{reason}")
        [{"name", name}, {"place_id", place_id}]
    end
  end

  defp parse_candidate(nil, name) do
    IO.puts("ERROR couldn't find candidate")

    [{"name", name}]
  end

  defp parse_place_response(body) do
    result =
      body
      |> Jason.decode!()
      |> Map.get("result", %{})

    result
    |> Map.take(~w(name formatted_address formatted_phone_number website))
    |> Map.merge(parse_coordinates(result))
  end

  defp parse_coordinates(%{
         "geometry" => %{"location" => %{"lat" => latitude, "lng" => longitude}}
       }) do
    %{"latitude" => latitude, "longitude" => longitude}
  end

  defp parse_coordinates(_result), do: %{}
end
