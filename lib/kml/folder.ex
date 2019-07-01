defmodule Kml.Folder do
  alias Kml.{Folder, Placemark}

  @type placemark :: Placemark.t()

  @type t :: %Folder{
          name: binary,
          placemarks: [placemark]
        }

  defstruct name: "", placemarks: []
end
