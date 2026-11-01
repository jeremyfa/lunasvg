// Ported from lunasvg 3.5.0: include/lunasvg.h, source/lunasvg.cpp (Document)
// Original code Copyright (c) 2020-2026 Samuel Ugochukwu, licensed under MIT.
// Modified: translated from C++ to Haxe. See LICENSE.
package lunasvg;

import haxe.io.Bytes;
import lunasvg.Graphics;
import lunasvg.Node;
import lunasvg.SVGElement;
import lunasvg.SVGRenderState;
import plutovg.Utils.f32;

/**
 * A parsed SVG document (`lunasvg::Document`).
 *
 * ```haxe
 * var document = Document.loadFromData(svgString);
 * var bitmap = document.renderToBitmap(48, 48);
 * var rgba = bitmap.toRgba();
 * ```
 */
class Document {

    @:allow(lunasvg)
    var m_rootElement:Null<SVGRootElement> = null;

    function new() {}

    /**
     * Parses an SVG document. Returns null if it is not well formed or has
     * no `<svg>` root.
     */
    public static function loadFromData(data:String):Null<Document> {
        var document = new Document();
        if (!document.parse(data))
            return null;
        return document;
    }

    /**
     * Parses an SVG document from UTF-8 bytes. Invalid UTF-8 sequences are
     * replaced by U+FFFD (the C++ code reads raw bytes: only text content
     * can differ).
     */
    public static function loadFromBytes(bytes:Bytes):Null<Document> {
        return loadFromData(decodeUtf8(bytes));
    }

    static function decodeUtf8(bytes:Bytes):String {
        var buf = new StringBuf();
        var i = 0;
        var n = bytes.length;
        while (i < n) {
            var c = bytes.get(i);
            if (c < 0x80) {
                buf.addChar(c);
                i++;
                continue;
            }

            var count = c >= 0xF0 && c < 0xF5 ? 3 : (c >= 0xE0 ? 2 : (c >= 0xC2 && c < 0xE0 ? 1 : -1));
            if (c >= 0xF5)
                count = -1;
            var cp = count == 3 ? c & 0x07 : (count == 2 ? c & 0x0F : c & 0x1F);
            var ok = count > 0 && i + count < n + 1;
            if (ok) {
                for (k in 1...count + 1) {
                    if (i + k >= n) {
                        ok = false;
                        break;
                    }
                    var cc = bytes.get(i + k);
                    if (cc & 0xC0 != 0x80) {
                        ok = false;
                        break;
                    }
                    cp = (cp << 6) | (cc & 0x3F);
                }
            }

            if (ok && ((count == 2 && cp < 0x800) || (count == 3 && (cp < 0x10000 || cp > 0x10FFFF)) || (cp >= 0xD800 && cp < 0xE000)))
                ok = false;
            if (ok) {
                buf.addChar(cp);
                i += count + 1;
            } else {
                buf.addChar(0xFFFD);
                i++;
            }
        }

        return buf.toString();
    }

    #if sys
    public static function loadFromFile(filename:String):Null<Document> {
        if (!sys.FileSystem.exists(filename))
            return null;
        return loadFromBytes(sys.io.File.getBytes(filename));
    }
    #end

    function parse(data:String):Bool {
        return SVGParser.parse(this, data);
    }

    /**
     * Applies a CSS style sheet to the document (`svg { color: white }`).
     */
    public function applyStyleSheet(content:String):Void {
        SVGParser.applyStyleSheet(this, content);
    }

    /**
     * The elements matching a CSS selector list, in document order.
     */
    public function querySelectorAll(content:String):ElementList {
        return [for (element in SVGParser.querySelectorAll(this, content)) new Element(element)];
    }

    /**
     * The intrinsic width of the document, in pixels.
     */
    public function width():Float {
        return rootElement(true).intrinsicWidth();
    }

    /**
     * The intrinsic height of the document, in pixels.
     */
    public function height():Float {
        return rootElement(true).intrinsicHeight();
    }

    /**
     * The bounding box of the painted content, in document coordinates.
     */
    public function boundingBox():Box {
        return Box.fromRect(rootElement(true).localTransform().mapRect(rootElement().paintBoundingBox()));
    }

    public function updateLayout():Void {
        m_rootElement.layoutIfNeeded();
    }

    public function forceLayout():Void {
        m_rootElement.forceLayout();
    }

    /**
     * Renders the document into `bitmap`, with `matrix` mapping document
     * coordinates to the bitmap (identity by default).
     */
    public function render(bitmap:Bitmap, ?matrix:Matrix):Void {
        if (bitmap.isNull())
            return;
        var canvas = Canvas.createFromBitmap(bitmap);
        var transform = matrix != null ? Transform.fromPublicMatrix(matrix) : new Transform();
        var state = new SVGRenderState(null, null, transform, Painting, canvas);
        rootElement(true).render(state);
    }

    /**
     * Renders the document into a new bitmap. Without size, the intrinsic
     * size is used; with one size missing (-1), it is computed from the
     * aspect ratio. `backgroundColor` is a straight 0xRRGGBBAA color.
     * Returns a null bitmap if the document has no size.
     */
    public function renderToBitmap(width:Int = -1, height:Int = -1, backgroundColor:Int = 0x00000000):Bitmap {
        var intrinsicWidth = rootElement(true).intrinsicWidth();
        var intrinsicHeight = rootElement().intrinsicHeight();
        if (intrinsicWidth == 0 || intrinsicHeight == 0)
            return new Bitmap();
        if (width <= 0 && height <= 0) {
            width = Std.int(Math.fceil(intrinsicWidth));
            height = Std.int(Math.fceil(intrinsicHeight));
        } else if (width > 0 && height <= 0) {
            height = Std.int(Math.fceil(f32(f32(width * intrinsicHeight) / intrinsicWidth)));
        } else if (height > 0 && width <= 0) {
            width = Std.int(Math.fceil(f32(f32(height * intrinsicWidth) / intrinsicHeight)));
        }

        var xScale = f32(width / intrinsicWidth);
        var yScale = f32(height / intrinsicHeight);

        var matrix = new Matrix(xScale, 0, 0, yScale, 0, 0);
        var bitmap = Bitmap.create(width, height);
        if (backgroundColor != 0)
            bitmap.clear(backgroundColor);
        render(bitmap, matrix);
        return bitmap;
    }

    /**
     * The topmost pointable element whose bounding box contains (x, y).
     */
    public function elementFromPoint(x:Float, y:Float):Element {
        return new Element(rootElement(true).elementFromPoint(x, y));
    }

    public function getElementById(id:String):Element {
        return new Element(m_rootElement.getElementById(id));
    }

    public function documentElement():Element {
        return new Element(m_rootElement);
    }

    function rootElement(layoutIfNeeded:Bool = false):SVGRootElement {
        if (layoutIfNeeded)
            m_rootElement.layoutIfNeeded();
        return m_rootElement;
    }

}
