// Haxe-only module of the lunasvg port: replaces the plutovg font API
// (plutovg_font_face_t, plutovg_font_face_cache_t) used by source/graphics.h
// and source/graphics.cpp of lunasvg 3.5.0.
// Original code Copyright (c) 2020-2026 Samuel Ugochukwu, licensed under MIT.
// Modified: translated from C++ to Haxe. See LICENSE.
package lunasvg;

/**
 * Font metrics at a given size, in pixels. `ascent` is positive (above the
 * baseline), `descent` is negative (below the baseline), like plutovg.
 */
class FontMetrics {

    public var ascent:Float = 0;

    public var descent:Float = 0;

    public var lineGap:Float = 0;

    public function new() {}

}

/**
 * A font face able to give metrics and glyph outlines. This replaces
 * `plutovg_font_face_t`, which the plutovg port does not include.
 *
 * Coordinates follow plutovg: the y axis points down, the glyph origin is on
 * the baseline.
 */
interface FontFace {

    /**
     * Fills `metrics` with the ascent, descent and line gap of the face at
     * `size` pixels (`plutovg_font_face_get_metrics()`).
     */
    function getMetrics(size:Float, metrics:FontMetrics):Void;

    /**
     * Advance width of the glyph of `codepoint` at `size` pixels.
     */
    function getGlyphAdvance(codepoint:Int, size:Float):Float;

    /**
     * Bounding box of the glyph of `codepoint` at `size` pixels, relative to
     * its origin (y down), stored into `extents`
     * (`plutovg_font_face_get_glyph_metrics()`). Only used for the x-height
     * (glyph 'x').
     */
    function getGlyphExtents(codepoint:Int, size:Float, extents:plutovg.Rect):Void;

    /**
     * Appends the outline of the glyph of `codepoint` at `size` pixels to
     * `path`, with its origin at (`x`, `y`), and returns its advance width
     * (`plutovg_font_face_get_glyph_path()`).
     */
    function addGlyphPath(codepoint:Int, size:Float, x:Float, y:Float, path:plutovg.Path):Float;

}

/**
 * Resolves font families to faces. Register one with
 * `Lunasvg.setFontProvider()` to render `<text>`: without a provider, text
 * elements are laid out with empty metrics and draw nothing.
 */
interface FontProvider {

    /**
     * Returns the face for `family` (already unquoted, for instance
     * "Noto Sans" or a generic family like "sans-serif"), or null if this
     * provider has no such family. An empty `family` asks for a default face.
     */
    function getFontFace(family:String, bold:Bool, italic:Bool):Null<FontFace>;

}
