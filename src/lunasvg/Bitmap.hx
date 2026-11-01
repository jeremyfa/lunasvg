// Ported from lunasvg 3.5.0: include/lunasvg.h, source/lunasvg.cpp (Bitmap)
// Original code Copyright (c) 2020-2026 Samuel Ugochukwu, licensed under MIT.
// Modified: translated from C++ to Haxe. See LICENSE.
package lunasvg;

import haxe.io.Bytes;

/**
 * A rendered image: premultiplied ARGB pixels in a `plutovg.Surface`
 * (`lunasvg::Bitmap`). A bitmap without surface is "null" (`isNull()`).
 */
class Bitmap {

    var m_surface:Null<plutovg.Surface>;

    /**
     * Creates a bitmap over `surface` (or a null bitmap).
     */
    public function new(?surface:plutovg.Surface) {
        m_surface = surface;
    }

    /**
     * `Bitmap(width, height)`: a new transparent bitmap. It is null if the
     * size is invalid.
     */
    public static function create(width:Int, height:Int):Bitmap {
        return new Bitmap(plutovg.Surface.create(width, height));
    }

    /**
     * `Bitmap(data, width, height, stride)`: a bitmap over existing
     * premultiplied ARGB pixels (no copy).
     */
    public static function createForData(data:Bytes, width:Int, height:Int, stride:Int):Bitmap {
        return new Bitmap(plutovg.Surface.createForData(data, width, height, stride));
    }

    /**
     * The pixels: premultiplied ARGB, one little-endian 32-bit value per
     * pixel (B, G, R, A bytes in memory), `stride` bytes per row.
     */
    public function data():Null<Bytes> {
        if (m_surface != null)
            return m_surface.data;
        return null;
    }

    public function width():Int {
        if (m_surface != null)
            return m_surface.width;
        return 0;
    }

    public function height():Int {
        if (m_surface != null)
            return m_surface.height;
        return 0;
    }

    public function stride():Int {
        if (m_surface != null)
            return m_surface.stride;
        return 0;
    }

    /**
     * Fills the bitmap with `value`, a straight 0xRRGGBBAA color.
     */
    public function clear(value:Int):Void {
        if (m_surface == null)
            return;
        var color = new plutovg.Color();
        color.initRgba32(value);
        m_surface.clear(color);
    }

    /**
     * Converts the pixels in place to straight (not premultiplied) RGBA
     * bytes. The bitmap must not be rendered to afterwards.
     */
    public function convertToRGBA():Void {
        if (m_surface == null)
            return;
        plutovg.Surface.convertArgbToRgba(m_surface.data, m_surface.data, m_surface.width, m_surface.height, m_surface.stride);
    }

    /**
     * Returns a copy of the pixels as straight RGBA bytes (Haxe addition).
     */
    public function toRgba():Null<Bytes> {
        if (m_surface == null)
            return null;
        return m_surface.toRgba();
    }

    public inline function isNull():Bool {
        return m_surface == null;
    }

    public inline function valid():Bool {
        return !isNull();
    }

    public inline function surface():Null<plutovg.Surface> {
        return m_surface;
    }

}
