# Kml

Simple [Google My Maps](https://www.google.com/mymaps) KML text file to
CSV conversor.

## Installation

```
$ mix deps.get
$ mix compile
```

## Configuration

Needs `config/config.secret.exs` file with:

```
use Mix.Config

config :kml, gmaps_key: "API_KEY_OR_EMPTY_IF_NOT_USED"
```


## Use

This creates a CSV file for each layer (KML folder).

```
$ mix kml.to_csv file.kml -o destination/folder
```

Options:
 - `--option, -o` sets CSV files destination folder.
 - `--places, -p` gets place information from google places by name and closeness.
