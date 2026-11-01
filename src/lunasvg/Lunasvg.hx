// Ported from lunasvg 3.5.0: include/lunasvg.h, source/lunasvg.cpp (C API),
// and the base64 decoder of plutovg 1.3.3 source/plutovg-surface.c
// (plutovg_surface_load_from_image_base64), used for data URIs.
// Original code Copyright (c) 2020-2026 Samuel Ugochukwu, licensed under MIT.
// Modified: translated from C/C++ to Haxe. See LICENSE.
package lunasvg;

import haxe.io.Bytes;
import lunasvg.FontProvider;
import lunasvg.Graphics.FontFaceCache;

/**
 * Library level functions: version, fonts and image decoding hooks.
 */
class Lunasvg {

    public static inline final VERSION_MAJOR:Int = 3;

    public static inline final VERSION_MINOR:Int = 5;

    public static inline final VERSION_MICRO:Int = 0;

    public static inline final VERSION:Int = VERSION_MAJOR * 10000 + VERSION_MINOR * 100 + VERSION_MICRO;

    public static inline final VERSION_STRING:String = "3.5.0";

    /**
     * Decodes image file bytes (PNG, JPEG...) into a surface. lunasvg uses
     * stb_image, which is not ported: without a decoder, `<image>` elements
     * are ignored.
     */
    public static var imageDecoder:Null<Bytes->Null<plutovg.Surface>> = null;

    /**
     * Loads the bytes of an external resource referenced by `<image href>`
     * (anything but a data URI). Without a loader, external images are
     * ignored.
     */
    public static var resourceLoader:Null<String->Null<Bytes>> = null;

    public static inline function version():Int {
        return VERSION;
    }

    public static inline function versionString():String {
        return VERSION_STRING;
    }

    /**
     * Sets the font provider used to resolve `font-family` (null removes
     * it). See `FontProvider`.
     */
    public static function setFontProvider(provider:Null<FontProvider>):Void {
        FontFaceCache.fontFaceCache().provider = provider;
    }

    /**
     * `lunasvg_add_font_face_from_data()`: registers `face` for `family`,
     * looked up before the font provider.
     */
    public static function addFontFace(family:String, bold:Bool, italic:Bool, face:FontFace):Bool {
        return FontFaceCache.fontFaceCache().addFontFace(family, bold, italic, face);
    }

    static function decodeImage(bytes:Null<Bytes>):Bitmap {
        if (bytes == null || imageDecoder == null)
            return new Bitmap();
        return new Bitmap(imageDecoder(bytes));
    }

    /**
     * Loads an external image through `resourceLoader` and `imageDecoder`.
     */
    public static function loadImageFile(href:String):Bitmap {
        if (resourceLoader == null)
            return new Bitmap();
        return decodeImage(resourceLoader(href));
    }

    /**
     * `plutovg_surface_load_from_image_base64()`: decodes base64 data
     * (whitespace allowed) and then the image.
     */
    public static function decodeImageBase64(data:String):Bitmap {
        var bytes = decodeBase64(data);
        if (bytes == null)
            return new Bitmap();
        return decodeImage(bytes);
    }

    /**
     * The permissive base64 decoder of plutovg. Returns null on error.
     */
    public static function decodeBase64(data:String):Null<Bytes> {
        var length = data.length;
        var output = Bytes.alloc(length);
        var outputLength = 0;
        var equalsSignCount = 0;
        for (i in 0...length) {
            var cc = StringTools.fastCodeAt(data, i);
            if (cc == '='.code) {
                ++equalsSignCount;
            } else if (cc == '+'.code || cc == '/'.code || (cc >= '0'.code && cc <= '9'.code) || (cc >= 'a'.code && cc <= 'z'.code)
                || (cc >= 'A'.code && cc <= 'Z'.code)) {
                if (equalsSignCount > 0)
                    return null;
                output.set(outputLength++, base64Value(cc));
            } else if (!(cc == ' '.code || cc == '\t'.code || cc == '\n'.code || cc == '\r'.code)) {
                return null;
            }
        }

        if (outputLength == 0 || equalsSignCount > 2 || (outputLength % 4) == 1)
            return null;
        outputLength -= Std.int((outputLength + 3) / 4);
        if (outputLength == 0)
            return null;

        var sidx = 0;
        var didx = 0;
        if (outputLength > 1) {
            while (didx < outputLength - 2) {
                var s0 = output.get(sidx + 0);
                var s1 = output.get(sidx + 1);
                var s2 = output.get(sidx + 2);
                var s3 = output.get(sidx + 3);
                output.set(didx + 0, ((s0 << 2) & 255) | ((s1 >> 4) & 3));
                output.set(didx + 1, ((s1 << 4) & 255) | ((s2 >> 2) & 15));
                output.set(didx + 2, ((s2 << 6) & 255) | ((s3 >> 0) & 63));
                sidx += 4;
                didx += 3;
            }
        }

        if (didx < outputLength)
            output.set(didx, ((output.get(sidx + 0) << 2) & 255) | ((output.get(sidx + 1) >> 4) & 3));
        if (++didx < outputLength) {
            output.set(didx, ((output.get(sidx + 1) << 4) & 255) | ((output.get(sidx + 2) >> 2) & 15));
        }

        return output.sub(0, outputLength);
    }

    static inline function base64Value(cc:Int):Int {
        if (cc >= 'A'.code && cc <= 'Z'.code)
            return cc - 'A'.code;
        if (cc >= 'a'.code && cc <= 'z'.code)
            return cc - 'a'.code + 26;
        if (cc >= '0'.code && cc <= '9'.code)
            return cc - '0'.code + 52;
        if (cc == '+'.code)
            return 62;
        return 63;
    }

}
