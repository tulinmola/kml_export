# Kml

Simple [Google My Maps](https://www.google.com/mymaps) KML text file to
CSV conversor.

## Installation

```
$ mix deps.get
$ mix compile
```

## Use

This creates a CSV file for each layer (KML folder).

```
$ mix kml.to_csv file.kml -o destination/folder
```

Options:
 - `--option, -o` sets CSV files destination folder.
