defmodule Mix.Tasks.Kml.ToCsv do
  use Mix.Task

  @shortdoc "converts KML to CSV files"

  @spec run([binary]) :: :ok
  def run(argv) do
    Mix.Task.run("app.start")

    {opts, [filename]} =
      OptionParser.parse!(argv,
        strict: [output: :string],
        aliases: [o: :output]
      )

    output = Keyword.get(opts, :output, ".")
    ensure_exists(output)

    kml = Kml.parse(filename)

    Enum.each(kml.folders, &write_csv(kml, &1, output))
  end

  defp write_csv(_kml, folder, output) do
    path = Path.join(output, "#{folder.name}.csv")

    content = Kml.Csv.convert(folder)
    File.write!(path, content)
  end

  defp ensure_exists(path) do
    File.mkdir_p!(path)
  end
end
