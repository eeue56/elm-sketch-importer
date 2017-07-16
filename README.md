# elm-sketch-importer

Takes a Sketch file, and generates Elm out of it. This is particularly useful if you want to quickly export some part of a design into Elm.

This is a work in progress. PRs are welcome!


## Installation 

```
npm install -g elm-sketch-importer
```

## Usage


```
Usage: [sketchfile]

Options:
  -h, --help         Show help                                         [boolean]
  -o, --output       Configure the output directory for generated Elm
                                                          [default: "generated"]
  --ef, --elmformat  Specify the location of the elm-format binary
                                                         [default: "elm-format"]

Examples:
  elm-sketch-importer ~/Documents/example.sketch
```


## Support

## Layers

### Shapes and rects

| Feature | Supported? |
|---------|-------------|
| Rectangles | :white_check_mark: |
| Layer positions | :white_check_mark: |
| Layer sizes | :white_check_mark: |
| Multiple layers | :white_check_mark: |
| Fills | :white_check_mark: |
| Border | :warning: |
| Border color | :warning: |
| Colored fills | :white_check_mark: |
| Other shapes | :warning: |
| Groups | :warning: |
| Slices | :warning: |
| Images | :white_check_mark: |


###  Text

Right now, long text is not correctly exported. This is down to the fact that BPLists are a little difficult to parse in Elm. Support will be coming soon, once I've finished the parser!

| Feature | Supported? |
|---------|------------|
| Short text       | :white_check_mark: |
| Long text | :warning: |
| Horizional/vertical flips | :white_check_mark: |
| Position | :white_check_mark: |
| Size | :warning: |
| Color | :warning: |
| Font | :warning: |


## Roadmap

This roadmap intends to be a rough priority list. No dates nor time are fixed -- but the more PRs to help, the faster things get done :)

- Relative layout instead of fixed pixels
- Full support for importing Sketch files
	- Make sure that no features remain unsupported
- Export views to Sketch
- Generating elm-css or style-element based views

