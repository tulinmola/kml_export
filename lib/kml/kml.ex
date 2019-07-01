defmodule Kml do
  alias Kml.{Folder, Parser}

  @type folder :: Folder.t()

  @type t :: %Kml{
          name: binary,
          folders: [folder]
        }

  defstruct name: "", folders: []

  @spec parse(binary) :: t
  def parse(path) do
    Parser.do_parse(path)
  end
end
