# lunasvg (Haxe)

A pure Haxe port of [lunasvg](https://github.com/sammycage/lunasvg) **3.5.0**, the SVG rendering library written in C++ by **Samuel Ugochukwu**.

It parses SVG documents and renders them with the Haxe port of [plutovg](https://github.com/sammycage/plutovg) 1.3.3 (the library lunasvg 3.5.0 bundles), exactly like the C++ library does. Supported:

- shapes and paths: `rect`, `circle`, `ellipse`, `line`, `polyline`, `polygon`, `path`;
- structure: `svg` (nested), `g`, `a`, `defs`, `use`, `symbol`, `style`, `viewBox`, `preserveAspectRatio`, `transform`, `display`, `visibility`, `overflow`;
- painting: fill and stroke (colors, `currentColor`, opacity, fill rule, width, caps, joins, miter limit, dashes), group `opacity`, markers;
- paint servers: `linearGradient`, `radialGradient` (units, spread methods, `href` inheritance), `pattern`;
- `clipPath` and `mask` (luminance and alpha);
- CSS: `<style>` sheets (type, class, id, attribute and pseudo-class selectors, combinators, `!important`), `style` attributes;
- `image` (data URIs and external files, through a decoder you provide);
- `text` and `tspan` layout (positions, rotation, anchors, baselines, letter and word spacing, `textLength`), through a font provider you provide;
- a small DOM: find elements by id or CSS selector, read and change attributes at runtime, bounding boxes, hit testing.

It has no dependency besides the plutovg port and runs on every Haxe target. The output matches the native library pixel for pixel on the test suite (see [Tests](#tests)).

## Not ported

- **Fonts**: lunasvg draws text with plutovg's font support (stb_truetype), which the plutovg port does not include. Text goes through the `lunasvg.FontProvider` interface instead (see [Text](#text)). Without a provider, `<text>` is laid out with empty metrics and draws nothing.
- **Image decoding**: lunasvg decodes PNG, JPEG... with stb_image. Set `Lunasvg.imageDecoder` to decode `<image>` data (and `Lunasvg.resourceLoader` for external files). Without them, `<image>` is ignored.
- **PNG output** (`Bitmap::writeToPng`): use `bitmap.toRgba()` and the encoder of your choice.
- `lunasvg_add_font_face_from_file` and system font loading. `Lunasvg.addFontFace()` registers a `FontFace` for a family name.

Like the C++ library, animations, scripts and filters are not supported.

## Usage

```haxe
import lunasvg.Document;

var document = Document.loadFromData(svgString); // null if invalid
trace(document.width(), document.height());      // intrinsic size

// Lucide style icon: stroke="currentColor"
document.documentElement().setAttribute("color", "#ffffff");

// render at 48x48 (or renderToBitmap() for the intrinsic size,
// or renderToBitmap(48, -1) to keep the aspect ratio)
var bitmap = document.renderToBitmap(48, 48);
var rgba = bitmap.toRgba(); // straight RGBA bytes, ready for a texture

// bitmap.data(): premultiplied ARGB (plutovg layout), bitmap.surface(): plutovg.Surface
```

Runtime changes and queries:

```haxe
var circle = document.getElementById("dot");
circle.setAttribute("fill", "red");          // attributes and CSS properties
circle.setAttribute("transform", "translate(10 0)");
trace(circle.getAttribute("r"));
trace(circle.getBoundingBox(), circle.getGlobalBoundingBox());

for (element in document.querySelectorAll("path.accent"))
    element.setAttribute("stroke", "#3b82f6");

document.applyStyleSheet("svg { color: white } .muted { opacity: 0.5 }");

// render into an existing bitmap with a matrix
var target = lunasvg.Bitmap.create(256, 256);
document.render(target, lunasvg.Matrix.scaled(4, 4));
```

The document is laid out again automatically after a change, before the next render or query.

### API overview

| Haxe | C++ |
|---|---|
| `Document.loadFromData(string)`, `loadFromBytes(bytes)`, `loadFromFile(path)` (sys) | `Document::loadFromData`, `loadFromFile` |
| `document.width()`, `height()`, `boundingBox()` | same |
| `document.render(bitmap, ?matrix)`, `renderToBitmap(width, height, backgroundColor)` | same |
| `document.getElementById(id)`, `querySelectorAll(selectors)`, `documentElement()`, `elementFromPoint(x, y)` | same |
| `document.applyStyleSheet(css)`, `updateLayout()`, `forceLayout()` | same |
| `Element`: `hasAttribute`, `getAttribute`, `setAttribute`, `render`, `renderToBitmap`, `getBoundingBox`, `getLocalBoundingBox`, `getGlobalBoundingBox`, `getLocalMatrix`, `getGlobalMatrix`, `children` | same |
| `Node`, `TextNode` (`data()`, `setData()`) | same (`==` is `equals()`) |
| `Bitmap`: `create(w, h)`, `createForData(...)`, `data()`, `width()`, `height()`, `stride()`, `clear(rgba)`, `convertToRGBA()`, `toRgba()`, `surface()` | same (`toRgba()` added) |
| `Matrix` (a, b, c, d, e, f, `mul`, `multiply`, `translate`, `scale`, `rotate`, `shear`, `inverse`...), `Box` | same (`operator*` is `mul()`) |
| `Lunasvg.version()`, `setFontProvider()`, `addFontFace()`, `imageDecoder`, `resourceLoader` | `lunasvg_version()`, `lunasvg_add_font_face_*` |

Colors given to `clear()` and `renderToBitmap()` are 0xRRGGBBAA, like the C++ API.

## Text

Text needs a `lunasvg.FontProvider`, which returns `FontFace` objects for family names:

```haxe
class MyFontProvider implements lunasvg.FontProvider {
    public function new() {}
    public function getFontFace(family:String, bold:Bool, italic:Bool):Null<lunasvg.FontProvider.FontFace> {
        // family is unquoted ("Noto Sans", "sans-serif"...), "" asks for a default face
        return myFaces.get(family);
    }
}

lunasvg.Lunasvg.setFontProvider(new MyFontProvider());
```

A `FontFace` gives the metrics (`getMetrics`: ascent, descent as a negative value, line gap), glyph advances (`getGlyphAdvance`), glyph extents (`getGlyphExtents`, used for the x-height) and glyph outlines (`addGlyphPath`, which appends the outline at a given origin to a `plutovg.Path`, y axis down, and returns the advance). All values are in pixels for the requested size. This mirrors what lunasvg takes from plutovg's font API, so a TrueType library can be plugged in without changing lunasvg. Faces registered with `Lunasvg.addFontFace()` are looked up first, then the provider, then the generic family fallbacks of lunasvg (`sans-serif` to "Arial" and so on).

## Implementation notes

- The files follow the C++ sources: `Graphics.hx` is graphics.h/.cpp, `SVGElement.hx` is svgelement.h/.cpp, and so on (`SVGParser.hx` holds `Document::parse` and the CSS engine of svgparser.cpp; `Document.hx`, `Node.hx`, `Bitmap.hx`, `Matrix.hx`, `Box.hx` and `Lunasvg.hx` come from lunasvg.h/.cpp). Private fields keep their C++ names (`m_fill_rule`), methods are camelCase (`fill_rule()` is `fillRule()`).
- C++ multiple inheritance (`SVGFitToViewBox`, `SVGURIReference`) becomes a member object with delegating methods.
- `Rect`, `Point`, `Transform` are mutable classes standing for C++ value types: they are copied (`clone()`) where the C++ code copies them before changing them. `Path` emulates the reference counting of `plutovg_path_t`, which decides whether a cleared path stays allocated.
- lunasvg computes in C `float`: values are rounded to float32 (`plutovg.Utils.f32()`) at the same places as the C++ code, so the output is bit-exact. Products that the C++ compiler could fuse into multiply-adds are kept separate.
- `PropertyID` and `ElementID` are plain abstracts over Int (not `enum abstract`), because enum abstract values would shadow type names like `Color` or `Rect` in every module importing them.
- Scratch state is shared statically: the library is not meant to be used from several threads at once.

## Tests

`test/` contains a runner without dependencies besides plutovg (expected next to this library, in `../plutovg`):

```sh
cd test
./run.sh /path/to/haxe                                        # JS, runs with node
./run-cpp.sh /path/to/hxcpp /path/to/haxe /path/to/haxelib     # hxcpp, local .haxelib
```

Runner options: `--lucide <dir>` (Lucide icons folder), `--raw <dir>` (native raw dumps, to measure the maximum channel difference of differing cases), `--out <dir>` (write the Haxe dumps), `--only <text>`, `--verbose`.

It runs unit tests of the API, then renders two case lists and compares a hash of every bitmap with hashes produced by native lunasvg 3.5.0 (`test/reference/*.hashes`):

- `cases-resvg.txt`: 873 files of the [resvg](https://github.com/linebender/resvg) test suite (shapes, structure, painting, paint servers, masking, text), at their intrinsic size;
- `cases-lucide.txt`: the 1830 [Lucide](https://lucide.dev) icons at 24x24 and 48x48, white `currentColor` on transparent. The icons are not included: pass their folder with `--lucide`.

Text cases (no font provider) and images other than 8-bit PNG data URIs are rendered (they must not crash) but not compared. To decode PNG data URIs, the test runner uses the [format](https://github.com/HaxeFoundation/format) library (expected in `../format`, test only).

Current results: every compared case is identical to the native output (797 resvg cases, 3660 Lucide renders), on JS and C++.

`test/reference-gen/` rebuilds the native reference: `build.sh` compiles lunasvg 3.5.0 and its bundled plutovg with `-ffp-contract=off` and without system fonts, renders the case lists with `refgen.cpp` and writes the hash files (and raw dumps with `--raw`):

```sh
LUCIDE_DIR=/path/to/lucide/icons ./reference-gen/build.sh /path/to/lunasvg /tmp/lunasvg-ref --raw
```

## License

MIT, like lunasvg: Copyright (c) 2020-2026 Samuel Ugochukwu. See [LICENSE](LICENSE).

Test files: `test/svg/resvg/` comes from the resvg test suite, Copyright 2017 the Resvg Authors, dual licensed under Apache-2.0 or MIT (`test/svg/resvg/LICENSE-APACHE`, `test/svg/resvg/LICENSE-MIT`). The Lucide icons used by the tests are not included; `test/reference/cases-lucide.hashes` is derived from them: Lucide is licensed under ISC (Copyright (c) 2026 Lucide Icons and Contributors), with icons derived from Feather under MIT (Copyright (c) 2013-present Cole Bemis).
