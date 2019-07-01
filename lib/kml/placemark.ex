defmodule Kml.Placemark do
  alias Kml.Placemark

  @type pair :: {binary, any}

  @type t :: %Placemark{
          data: [pair]
        }

  defstruct data: []
end
