defmodule Kml do
  alias Kml.{Folder, Parser}

  @type option :: {:place, boolean}
  @type folder :: Folder.t()

  @type t :: %Kml{
          name: binary,
          folders: [folder]
        }

  defstruct name: "", folders: []

  @spec parse(binary, [option]) :: t
  def parse(path, opts) do
    Parser.do_parse(path, opts)
  end
end
