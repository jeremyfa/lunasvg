// Ported from lunasvg 3.5.0: source/graphics.h, source/graphics.cpp
// Original code Copyright (c) 2020-2026 Samuel Ugochukwu, licensed under MIT.
// Modified: translated from C++ to Haxe. See LICENSE.
package lunasvg;

import lunasvg.FontProvider;
import plutovg.Utils.f32;

typedef LineCap = plutovg.LineCap;

typedef LineJoin = plutovg.LineJoin;

typedef FillRule = plutovg.FillRule;

typedef SpreadMethod = plutovg.SpreadMethod;

typedef TextureType = plutovg.TextureType;

/**
 * Operators used to composite layers (`BlendMode` in graphics.h).
 */
enum abstract BlendMode(Int) from Int to Int {

    var Src = 1;

    var Src_Over = 3;

    var Dst_In = 6;

    var Dst_Out = 8;

}

/**
 * A 32-bit ARGB color, not premultiplied (`lunasvg::Color`).
 */
abstract Color(Int) {

    public static final Transparent:Color = new Color(0x00000000);

    public static final Black:Color = new Color(0xFF000000);

    public static final White:Color = new Color(0xFFFFFFFF);

    public inline function new(value:Int) {
        this = value;
    }

    public static inline function fromRgba(r:Int, g:Int, b:Int, a:Int = 255):Color {
        return new Color(a << 24 | r << 16 | g << 8 | b);
    }

    public inline function alpha():Int {
        return (this >>> 24) & 0xff;
    }

    public inline function red():Int {
        return (this >>> 16) & 0xff;
    }

    public inline function green():Int {
        return (this >>> 8) & 0xff;
    }

    public inline function blue():Int {
        return this & 0xff;
    }

    public inline function alphaF():Float {
        return f32(alpha() / 255.0);
    }

    public inline function redF():Float {
        return f32(red() / 255.0);
    }

    public inline function greenF():Float {
        return f32(green() / 255.0);
    }

    public inline function blueF():Float {
        return f32(blue() / 255.0);
    }

    public inline function value():Int {
        return this;
    }

    public inline function isOpaque():Bool {
        return alpha() == 255;
    }

    public inline function isVisible():Bool {
        return alpha() > 0;
    }

    public inline function opaqueColor():Color {
        return new Color(this | 0xFF000000);
    }

    public function colorWithAlpha(opacity:Float):Color {
        var rgb = this & 0x00FFFFFF;
        var a = Std.int(f32(alpha() * clamp01(f32(opacity))));
        return new Color(rgb | a << 24);
    }

    static inline function clamp01(v:Float):Float {
        return v < 0 ? 0 : (v > 1 ? 1 : v);
    }

}

/**
 * A 2D point (`lunasvg::Point`). Mutable: copy it with `clone()`.
 */
class Point {

    public var x:Float;

    public var y:Float;

    public inline function new(x:Float = 0, y:Float = 0) {
        this.x = f32(x);
        this.y = f32(y);
    }

    public inline function clone():Point {
        return new Point(x, y);
    }

    public function move(dx:Float, dy:Float):Void {
        x = f32(x + dx);
        y = f32(y + dy);
    }

    public function scale(sx:Float, sy:Float):Void {
        x = f32(x * sx);
        y = f32(y * sy);
    }

    public inline function dot(p:Point):Float {
        return f32(f32(x * p.x) + f32(y * p.y));
    }

    public inline function sub(p:Point):Point {
        return new Point(x - p.x, y - p.y);
    }

    public inline function add(p:Point):Point {
        return new Point(x + p.x, y + p.y);
    }

}

/**
 * A 2D size (`lunasvg::Size`).
 */
class Size {

    public var w:Float;

    public var h:Float;

    public inline function new(w:Float = 0, h:Float = 0) {
        this.w = f32(w);
        this.h = f32(h);
    }

    public inline function clone():Size {
        return new Size(w, h);
    }

    public function expand(dw:Float, dh:Float):Void {
        w = f32(w + dw);
        h = f32(h + dh);
    }

    public function scale(sw:Float, sh:Float):Void {
        w = f32(w * sw);
        h = f32(h * sh);
    }

    public inline function isEmpty():Bool {
        return w <= 0 || h <= 0;
    }

    public inline function isZero():Bool {
        return w <= 0 && h <= 0;
    }

    public inline function isValid():Bool {
        return w >= 0 && h >= 0;
    }

}

/**
 * A rectangle (`lunasvg::Rect`). Mutable: copy it with `clone()`.
 */
class Rect {

    public var x:Float;

    public var y:Float;

    public var w:Float;

    public var h:Float;

    public inline function new(x:Float = 0, y:Float = 0, w:Float = 0, h:Float = 0) {
        this.x = f32(x);
        this.y = f32(y);
        this.w = f32(w);
        this.h = f32(h);
    }

    /** `Rect::Empty` */
    public static inline function empty():Rect {
        return new Rect(0, 0, 0, 0);
    }

    /** `Rect::Invalid` */
    public static inline function invalid():Rect {
        return new Rect(0, 0, -1, -1);
    }

    /** `Rect::Infinite` */
    public static inline function infinite():Rect {
        return new Rect(-FLT_MAX / 2, -FLT_MAX / 2, FLT_MAX, FLT_MAX);
    }

    public static inline final FLT_MAX:Float = 3.40282346638528859811704183484516925440e+38;

    public static inline function fromSize(size:Size):Rect {
        return new Rect(0, 0, size.w, size.h);
    }

    public static inline function fromBox(box:Box):Rect {
        return new Rect(box.x, box.y, box.w, box.h);
    }

    public inline function clone():Rect {
        return new Rect(x, y, w, h);
    }

    public inline function copyFrom(r:Rect):Rect {
        x = r.x;
        y = r.y;
        w = r.w;
        h = r.h;
        return this;
    }

    public function move(dx:Float, dy:Float):Void {
        x = f32(x + dx);
        y = f32(y + dy);
    }

    public function scale(sx:Float, sy:Float):Void {
        x = f32(x * sx);
        y = f32(y * sy);
        w = f32(w * sx);
        h = f32(h * sy);
    }

    public function inflate(dx:Float, dy:Float):Void {
        x = f32(x - dx);
        y = f32(y - dy);
        w = f32(w + f32(dx * 2));
        h = f32(h + f32(dy * 2));
    }

    public inline function contains(px:Float, py:Float):Bool {
        return px >= x && px <= f32(x + w) && py >= y && py <= f32(y + h);
    }

    public function intersected(rect:Rect):Rect {
        if (!rect.isValid())
            return clone();
        if (!isValid())
            return rect.clone();
        var l = Math.max(x, rect.x);
        var t = Math.max(y, rect.y);
        var r = Math.min(f32(x + w), f32(rect.x + rect.w));
        var b = Math.min(f32(y + h), f32(rect.y + rect.h));
        if (l >= r || t >= b)
            return Rect.empty();
        return new Rect(l, t, r - l, b - t);
    }

    public function united(rect:Rect):Rect {
        if (!rect.isValid())
            return clone();
        if (!isValid())
            return rect.clone();
        var l = Math.min(x, rect.x);
        var t = Math.min(y, rect.y);
        var r = Math.max(f32(x + w), f32(rect.x + rect.w));
        var b = Math.max(f32(y + h), f32(rect.y + rect.h));
        return new Rect(l, t, r - l, b - t);
    }

    public function intersect(o:Rect):Rect {
        return copyFrom(intersected(o));
    }

    public function unite(o:Rect):Rect {
        return copyFrom(united(o));
    }

    public inline function origin():Point {
        return new Point(x, y);
    }

    public inline function size():Size {
        return new Size(w, h);
    }

    public inline function right():Float {
        return f32(x + w);
    }

    public inline function bottom():Float {
        return f32(y + h);
    }

    public inline function isEmpty():Bool {
        return w <= 0 || h <= 0;
    }

    public inline function isZero():Bool {
        return w <= 0 && h <= 0;
    }

    public inline function isValid():Bool {
        return w >= 0 && h >= 0;
    }

    public function toString():String {
        return 'Rect($x, $y, $w, $h)';
    }

}

/**
 * An affine transform over a `plutovg.Matrix` (`lunasvg::Transform`).
 * Mutating methods change this transform and return it, like the C++ ones;
 * `mul()` (C++ `operator*`) returns a new transform.
 */
class Transform {

    public var m_matrix:plutovg.Matrix;

    public function new(a:Float = 1, b:Float = 0, c:Float = 0, d:Float = 1, e:Float = 0, f:Float = 0) {
        m_matrix = new plutovg.Matrix(a, b, c, d, e, f);
    }

    /** `Transform::Identity` */
    public static inline function identity():Transform {
        return new Transform();
    }

    public static function fromMatrix(matrix:plutovg.Matrix):Transform {
        var t = new Transform();
        t.m_matrix.copyFrom(matrix);
        return t;
    }

    public static function fromPublicMatrix(matrix:Matrix):Transform {
        return new Transform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.e, matrix.f);
    }

    public inline function clone():Transform {
        return fromMatrix(m_matrix);
    }

    public inline function matrix():plutovg.Matrix {
        return m_matrix;
    }

    /**
     * `operator*`: returns `this * transform` (`transform` is applied first).
     */
    public function mul(transform:Transform):Transform {
        var result = new Transform();
        result.m_matrix.multiply(transform.m_matrix, m_matrix);
        return result;
    }

    public function multiply(transform:Transform):Transform {
        m_matrix.multiply(transform.m_matrix, m_matrix);
        return this;
    }

    public function translate(tx:Float, ty:Float):Transform {
        return multiply(translated(tx, ty));
    }

    public function scale(sx:Float, sy:Float):Transform {
        return multiply(scaled(sx, sy));
    }

    public function rotate(angle:Float, cx:Float = 0, cy:Float = 0):Transform {
        return multiply(rotated(angle, cx, cy));
    }

    public function shear(shx:Float, shy:Float):Transform {
        return multiply(sheared(shx, shy));
    }

    public function postMultiply(transform:Transform):Transform {
        m_matrix.multiply(m_matrix, transform.m_matrix);
        return this;
    }

    public function postTranslate(tx:Float, ty:Float):Transform {
        return postMultiply(translated(tx, ty));
    }

    public function postScale(sx:Float, sy:Float):Transform {
        return postMultiply(scaled(sx, sy));
    }

    public function postRotate(angle:Float, cx:Float = 0, cy:Float = 0):Transform {
        return postMultiply(rotated(angle, cx, cy));
    }

    public function postShear(shx:Float, shy:Float):Transform {
        return postMultiply(sheared(shx, shy));
    }

    /**
     * The inverse transform. The C++ code leaves the result uninitialized
     * when the matrix is not invertible: identity is returned instead.
     */
    public function inverse():Transform {
        var inverse = new Transform();
        m_matrix.invert(inverse.m_matrix);
        return inverse;
    }

    public function invert():Transform {
        m_matrix.invert(m_matrix);
        return this;
    }

    public function reset():Void {
        m_matrix.initIdentity();
    }

    public function mapPoint(x:Float, y:Float):Point {
        return new Point(m_matrix.mapX(x, y), m_matrix.mapY(x, y));
    }

    public function mapRect(rect:Rect):Rect {
        if (!rect.isValid()) {
            return Rect.invalid();
        }

        var result = new plutovg.Rect(rect.x, rect.y, rect.w, rect.h);
        m_matrix.mapRect(result, result);
        return new Rect(result.x, result.y, result.w, result.h);
    }

    public function xScale():Float {
        return f32(Math.sqrt(f32(f32(m_matrix.a * m_matrix.a) + f32(m_matrix.b * m_matrix.b))));
    }

    public function yScale():Float {
        return f32(Math.sqrt(f32(f32(m_matrix.c * m_matrix.c) + f32(m_matrix.d * m_matrix.d))));
    }

    public function parse(data:String):Bool {
        return m_matrix.parse(data);
    }

    public static function translated(tx:Float, ty:Float):Transform {
        var t = new Transform();
        t.m_matrix.initTranslate(tx, ty);
        return t;
    }

    public static function scaled(sx:Float, sy:Float):Transform {
        var t = new Transform();
        t.m_matrix.initScale(sx, sy);
        return t;
    }

    public static function rotated(angle:Float, cx:Float, cy:Float):Transform {
        var t = new Transform();
        var matrix = t.m_matrix;
        if (cx == 0 && cy == 0) {
            matrix.initRotate(plutovg.Matrix.deg2rad(angle));
        } else {
            matrix.initTranslate(cx, cy);
            matrix.rotate(plutovg.Matrix.deg2rad(angle));
            matrix.translate(-cx, -cy);
        }

        return t;
    }

    public static function sheared(shx:Float, shy:Float):Transform {
        var t = new Transform();
        t.m_matrix.initShear(plutovg.Matrix.deg2rad(shx), plutovg.Matrix.deg2rad(shy));
        return t;
    }

    public function toString():String {
        return 'Transform(${m_matrix.a}, ${m_matrix.b}, ${m_matrix.c}, ${m_matrix.d}, ${m_matrix.e}, ${m_matrix.f})';
    }

}

typedef PathCommand = plutovg.PathCommand;

/**
 * Shared storage of a `Path`: emulates the reference counting of
 * `plutovg_path_t`, which decides whether a reset path stays allocated.
 */
private class PathData {

    public var path:plutovg.Path;

    public var refCount:Int = 1;

    public function new(path:plutovg.Path) {
        this.path = path;
    }

}

/**
 * A copy-on-write path (`lunasvg::Path`). Use `assign()` for the C++ copy
 * assignment.
 */
class Path {

    var m_data:Null<PathData> = null;

    public function new() {}

    /**
     * C++ copy assignment: shares the data of `path`.
     */
    public function assign(path:Path):Void {
        if (path.m_data == m_data)
            return;
        if (path.m_data != null)
            path.m_data.refCount++;
        release();
        m_data = path.m_data;
    }

    function release():Void {
        if (m_data != null) {
            m_data.refCount--;
            m_data = null;
        }
    }

    public function moveTo(x:Float, y:Float):Void {
        ensure().moveTo(x, y);
    }

    public function lineTo(x:Float, y:Float):Void {
        ensure().lineTo(x, y);
    }

    public function quadTo(x1:Float, y1:Float, x2:Float, y2:Float):Void {
        ensure().quadTo(x1, y1, x2, y2);
    }

    public function cubicTo(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float):Void {
        ensure().cubicTo(x1, y1, x2, y2, x3, y3);
    }

    public function arcTo(rx:Float, ry:Float, xAxisRotation:Float, largeArcFlag:Bool, sweepFlag:Bool, x:Float, y:Float):Void {
        ensure().arcTo(rx, ry, plutovg.Matrix.deg2rad(xAxisRotation), largeArcFlag, sweepFlag, x, y);
    }

    public function close():Void {
        ensure().close();
    }

    public function addEllipse(cx:Float, cy:Float, rx:Float, ry:Float):Void {
        ensure().addEllipse(cx, cy, rx, ry);
    }

    public function addRoundRect(x:Float, y:Float, w:Float, h:Float, rx:Float, ry:Float):Void {
        ensure().addRoundRect(x, y, w, h, rx, ry);
    }

    public function addRect(x:Float, y:Float, w:Float, h:Float):Void {
        ensure().addRect(x, y, w, h);
    }

    public function reset():Void {
        if (m_data == null)
            return;
        if (isUnique()) {
            m_data.path.reset();
        } else {
            release();
        }
    }

    public function boundingRect():Rect {
        if (m_data == null)
            return Rect.empty();
        var extents = new plutovg.Rect();
        m_data.path.extents(extents, false);
        return new Rect(extents.x, extents.y, extents.w, extents.h);
    }

    public function isEmpty():Bool {
        if (m_data != null)
            return m_data.path.size == 0;
        return true;
    }

    public inline function isUnique():Bool {
        return m_data.refCount == 1;
    }

    public inline function isNull():Bool {
        return m_data == null;
    }

    /**
     * The underlying plutovg path, or null.
     */
    public inline function data():Null<plutovg.Path> {
        return m_data != null ? m_data.path : null;
    }

    public function parse(data:String):Bool {
        ensure().reset();
        return m_data.path.parse(data);
    }

    function ensure():plutovg.Path {
        if (isNull()) {
            m_data = new PathData(new plutovg.Path());
        } else if (!isUnique()) {
            var clone = m_data.path.clone();
            release();
            m_data = new PathData(clone);
        }

        return m_data.path;
    }

}

/**
 * Iterates over the segments of a `Path` (`lunasvg::PathIterator`).
 */
class PathIterator {

    var m_elements:Array<Float>;

    var m_size:Int;

    var m_index:Int;

    public function new(path:Path) {
        var data = path.data();
        m_elements = data != null ? data.elements : [];
        m_size = data != null ? data.size : 0;
        m_index = 0;
    }

    /**
     * Stores the points of the current segment into `points` (3 points
     * needed) and returns its command.
     */
    public function currentSegment(points:Array<Point>):PathCommand {
        var slot = m_index << 1;
        var command:PathCommand = Std.int(m_elements[slot]);
        switch command {
            case CubicTo:
                points[0].x = m_elements[slot + 2];
                points[0].y = m_elements[slot + 3];
                points[1].x = m_elements[slot + 4];
                points[1].y = m_elements[slot + 5];
                points[2].x = m_elements[slot + 6];
                points[2].y = m_elements[slot + 7];
            default:
                points[0].x = m_elements[slot + 2];
                points[0].y = m_elements[slot + 3];
        }

        return command;
    }

    public inline function isDone():Bool {
        return m_index >= m_size;
    }

    public function next():Void {
        m_index += Std.int(m_elements[(m_index << 1) + 1]);
    }

}

/**
 * The font faces known to lunasvg (`lunasvg::FontFaceCache`): faces added
 * with `Lunasvg.addFontFace()`, then the faces of the font provider.
 */
class FontFaceCache {

    static var instance:Null<FontFaceCache> = null;

    var entries:Map<String, Array<FontFaceEntry>> = new Map();

    public var provider:Null<FontProvider> = null;

    function new() {}

    public function addFontFace(family:String, bold:Bool, italic:Bool, face:Null<FontFace>):Bool {
        if (face != null) {
            var list = entries.get(family);
            if (list == null) {
                list = [];
                entries.set(family, list);
            }
            list.unshift(new FontFaceEntry(bold, italic, face));
        }
        return face != null;
    }

    function cacheGet(family:String, bold:Bool, italic:Bool):Null<FontFace> {
        var list = entries.get(family);
        if (list != null && list.length > 0) {
            // plutovg_font_face_entry_select(): best score wins, ties keep
            // the previous selection.
            var selected = list[0];
            for (i in 1...list.length) {
                var entry = list[i];
                var a = (bold == entry.bold ? 1 : 0) + (italic == entry.italic ? 1 : 0);
                var b = (bold == selected.bold ? 1 : 0) + (italic == selected.italic ? 1 : 0);
                if (a > b)
                    selected = entry;
            }
            return selected.face;
        }

        if (provider != null && family.length > 0)
            return provider.getFontFace(family, bold, italic);
        return null;
    }

    public function getFontFace(family:String, bold:Bool, italic:Bool):Null<FontFace> {
        var face = cacheGet(family, bold, italic);
        if (face != null)
            return face;

        for (value in GENERIC_FALLBACKS) {
            if (value[0] == family || family.length == 0) {
                face = cacheGet(value[1], bold, italic);
                if (face == null && provider != null && family.length == 0)
                    face = provider.getFontFace("", bold, italic);
                return face;
            }
        }

        return null;
    }

    static final GENERIC_FALLBACKS:Array<Array<String>> = [
        ["sans-serif", "Arial"],
        ["serif", "Times New Roman"],
        ["monospace", "Courier New"],
        ["cursive", "Comic Sans MS"],
        ["fantasy", "Impact"]
    ];

    public static function fontFaceCache():FontFaceCache {
        if (instance == null)
            instance = new FontFaceCache();
        return instance;
    }

}

private class FontFaceEntry {

    public var bold:Bool;

    public var italic:Bool;

    public var face:FontFace;

    public function new(bold:Bool, italic:Bool, face:FontFace) {
        this.bold = bold;
        this.italic = italic;
        this.face = face;
    }

}

/**
 * A font face at a given size (`lunasvg::Font`).
 */
class Font {

    var m_face:Null<FontFace> = null;

    var m_size:Float = 0;

    var m_ascent:Float = 0;

    var m_descent:Float = 0;

    var m_lineGap:Float = 0;

    public function new(?face:FontFace, size:Float = 0) {
        m_face = face;
        m_size = f32(size);
        if (m_size > 0 && m_face != null) {
            var metrics = new FontMetrics();
            m_face.getMetrics(m_size, metrics);
            m_ascent = f32(metrics.ascent);
            m_descent = f32(metrics.descent);
            m_lineGap = f32(metrics.lineGap);
        }
    }

    public inline function ascent():Float {
        return m_ascent;
    }

    public inline function descent():Float {
        return m_descent;
    }

    public inline function height():Float {
        return f32(m_ascent - m_descent);
    }

    public inline function lineGap():Float {
        return m_lineGap;
    }

    public function xHeight():Float {
        var extents = new plutovg.Rect();
        if (m_size > 0 && m_face != null)
            m_face.getGlyphExtents('x'.code, m_size, extents);
        return f32(extents.h);
    }

    /**
     * Sum of the advances of `length` codepoints of `text` from `offset`.
     */
    public function measureText(text:Array<Int>, offset:Int, length:Int):Float {
        if (m_size > 0 && m_face != null) {
            var total = 0.0;
            for (i in offset...offset + length)
                total = f32(total + f32(m_face.getGlyphAdvance(text[i], m_size)));
            return total;
        }
        return 0;
    }

    public inline function face():Null<FontFace> {
        return m_face;
    }

    public inline function size():Float {
        return m_size;
    }

    public inline function isNull():Bool {
        return m_size <= 0 || m_face == null;
    }

}

typedef DashArray = Array<Float>;

/**
 * Stroke parameters (`lunasvg::StrokeData`).
 */
class StrokeData {

    var m_lineWidth:Float;

    var m_miterLimit:Float = 4;

    var m_dashOffset:Float = 0;

    var m_lineCap:LineCap = Butt;

    var m_lineJoin:LineJoin = Miter;

    var m_dashArray:DashArray = [];

    public function new(lineWidth:Float = 1) {
        m_lineWidth = f32(lineWidth);
    }

    public inline function setLineWidth(lineWidth:Float):Void {
        m_lineWidth = f32(lineWidth);
    }

    public inline function lineWidth():Float {
        return m_lineWidth;
    }

    public inline function setMiterLimit(miterLimit:Float):Void {
        m_miterLimit = f32(miterLimit);
    }

    public inline function miterLimit():Float {
        return m_miterLimit;
    }

    public inline function setDashOffset(dashOffset:Float):Void {
        m_dashOffset = f32(dashOffset);
    }

    public inline function dashOffset():Float {
        return m_dashOffset;
    }

    public inline function setDashArray(dashArray:DashArray):Void {
        m_dashArray = dashArray;
    }

    public inline function dashArray():DashArray {
        return m_dashArray;
    }

    public inline function setLineCap(lineCap:LineCap):Void {
        m_lineCap = lineCap;
    }

    public inline function lineCap():LineCap {
        return m_lineCap;
    }

    public inline function setLineJoin(lineJoin:LineJoin):Void {
        m_lineJoin = lineJoin;
    }

    public inline function lineJoin():LineJoin {
        return m_lineJoin;
    }

}

typedef GradientStop = plutovg.Paint.GradientStop;

typedef GradientStops = Array<GradientStop>;

/**
 * A drawing surface with an integer origin (`lunasvg::Canvas`): either a
 * whole bitmap, or a layer covering part of the device space.
 */
class Canvas {

    static inline final kMaxSize = 1 << 15;

    var m_surface:plutovg.Surface;

    var m_canvas:plutovg.Canvas;

    var m_translation:plutovg.Matrix;

    var m_x:Int;

    var m_y:Int;

    function new(surface:plutovg.Surface, x:Int, y:Int) {
        m_surface = surface;
        m_canvas = new plutovg.Canvas(surface);
        m_translation = new plutovg.Matrix(1, 0, 0, 1, -x, -y);
        m_x = x;
        m_y = y;
    }

    public static function createFromBitmap(bitmap:Bitmap):Canvas {
        return new Canvas(bitmap.surface(), 0, 0);
    }

    public static function create(x:Float, y:Float, width:Float, height:Float):Canvas {
        if (width <= 0 || height <= 0 || width >= kMaxSize || height >= kMaxSize)
            return new Canvas(plutovg.Surface.create(1, 1), 0, 0);
        var l = Std.int(Math.ffloor(x));
        var t = Std.int(Math.ffloor(y));
        var r = Std.int(Math.fceil(f32(x + width)));
        var b = Std.int(Math.fceil(f32(y + height)));
        return new Canvas(plutovg.Surface.create(r - l, b - t), l, t);
    }

    public static inline function createFromRect(extents:Rect):Canvas {
        return create(extents.x, extents.y, extents.w, extents.h);
    }

    public function setColor(color:Color):Void {
        setColorRgba(color.redF(), color.greenF(), color.blueF(), color.alphaF());
    }

    public function setColorRgba(r:Float, g:Float, b:Float, a:Float):Void {
        m_canvas.setRgba(r, g, b, a);
    }

    public function setLinearGradient(x1:Float, y1:Float, x2:Float, y2:Float, spread:SpreadMethod, stops:GradientStops, transform:Transform):Void {
        m_canvas.setLinearGradient(x1, y1, x2, y2, spread, stops, stops.length, transform.matrix());
    }

    public function setRadialGradient(cx:Float, cy:Float, r:Float, fx:Float, fy:Float, spread:SpreadMethod, stops:GradientStops, transform:Transform):Void {
        m_canvas.setRadialGradient(cx, cy, r, fx, fy, 0, spread, stops, stops.length, transform.matrix());
    }

    public function setTexture(source:Canvas, type:TextureType, opacity:Float, transform:Transform):Void {
        m_canvas.setTexture(source.surface(), type, opacity, transform.matrix());
    }

    public function fillPath(path:Path, fillRule:FillRule, transform:Transform):Void {
        m_canvas.setMatrix(m_translation);
        m_canvas.transform(transform.matrix());
        m_canvas.setFillRule(fillRule);
        m_canvas.setOperator(SrcOver);
        m_canvas.fillPath(path.data());
    }

    public function strokePath(path:Path, strokeData:StrokeData, transform:Transform):Void {
        m_canvas.setMatrix(m_translation);
        m_canvas.transform(transform.matrix());
        m_canvas.setLineWidth(strokeData.lineWidth());
        m_canvas.setMiterLimit(strokeData.miterLimit());
        m_canvas.setLineCap(strokeData.lineCap());
        m_canvas.setLineJoin(strokeData.lineJoin());
        m_canvas.setDashOffset(strokeData.dashOffset());
        m_canvas.setDashArray(strokeData.dashArray(), strokeData.dashArray().length);
        m_canvas.setOperator(SrcOver);
        m_canvas.strokePath(path.data());
    }

    /**
     * `plutovg_canvas_add_text()` with the glyph outlines of the font
     * provider.
     */
    function addText(text:Array<Int>, offset:Int, length:Int, font:Font, x:Float, y:Float):Void {
        var face = font.face();
        if (face == null || font.size() <= 0)
            return;
        var advanceWidth = 0.0;
        var path = m_canvas.path;
        for (i in offset...offset + length) {
            advanceWidth = f32(advanceWidth + f32(face.addGlyphPath(text[i], font.size(), f32(x + advanceWidth), y, path)));
        }
    }

    public function fillText(text:Array<Int>, offset:Int, length:Int, font:Font, origin:Point, transform:Transform):Void {
        m_canvas.setMatrix(m_translation);
        m_canvas.transform(transform.matrix());
        m_canvas.setFillRule(NonZero);
        m_canvas.setOperator(SrcOver);
        m_canvas.newPath();
        addText(text, offset, length, font, origin.x, origin.y);
        m_canvas.fill();
    }

    public function strokeText(text:Array<Int>, offset:Int, length:Int, strokeWidth:Float, font:Font, origin:Point, transform:Transform):Void {
        m_canvas.setMatrix(m_translation);
        m_canvas.transform(transform.matrix());
        m_canvas.setLineWidth(strokeWidth);
        m_canvas.setMiterLimit(4);
        m_canvas.setLineCap(Butt);
        m_canvas.setLineJoin(Miter);
        m_canvas.setDashOffset(0);
        m_canvas.setDashArray(null, 0);
        m_canvas.setOperator(SrcOver);
        m_canvas.newPath();
        addText(text, offset, length, font, origin.x, origin.y);
        m_canvas.stroke();
    }

    public function clipPath(path:Path, clipRule:FillRule, transform:Transform):Void {
        m_canvas.setMatrix(m_translation);
        m_canvas.transform(transform.matrix());
        m_canvas.setFillRule(clipRule);
        m_canvas.clipPath(path.data());
    }

    public function clipRect(rect:Rect, clipRule:FillRule, transform:Transform):Void {
        m_canvas.setMatrix(m_translation);
        m_canvas.transform(transform.matrix());
        m_canvas.setFillRule(clipRule);
        m_canvas.clipRect(rect.x, rect.y, rect.w, rect.h);
    }

    public function drawImage(image:Bitmap, dstRect:Rect, srcRect:Rect, transform:Transform):Void {
        var xScale = f32(dstRect.w / srcRect.w);
        var yScale = f32(dstRect.h / srcRect.h);
        var matrix = new plutovg.Matrix(xScale, 0, 0, yScale, -f32(srcRect.x * xScale), -f32(srcRect.y * yScale));
        m_canvas.setMatrix(m_translation);
        m_canvas.transform(transform.matrix());
        m_canvas.translate(dstRect.x, dstRect.y);
        m_canvas.setFillRule(NonZero);
        m_canvas.setOperator(SrcOver);
        m_canvas.setTexture(image.surface(), Plain, 1, matrix);
        m_canvas.fillRect(0, 0, dstRect.w, dstRect.h);
    }

    public function blendCanvas(canvas:Canvas, blendMode:BlendMode, opacity:Float):Void {
        var matrix = new plutovg.Matrix(1, 0, 0, 1, canvas.x(), canvas.y());
        m_canvas.setMatrix(m_translation);
        m_canvas.setOperator((blendMode : Int));
        m_canvas.setTexture(canvas.surface(), Plain, opacity, matrix);
        m_canvas.paint();
    }

    public function save():Void {
        m_canvas.save();
    }

    public function restore():Void {
        m_canvas.restore();
    }

    public function convertToLuminanceMask():Void {
        var width = m_surface.width;
        var height = m_surface.height;
        var rowStride = m_surface.stride >> 2;
        var pixels = m_surface.pixels;
        for (y in 0...height) {
            var row = rowStride * y;
            for (x in 0...width) {
                var pixel = pixels[row + x];
                var a = (pixel >>> 24) & 0xFF;
                var r = (pixel >>> 16) & 0xFF;
                var g = (pixel >>> 8) & 0xFF;
                var b = (pixel >>> 0) & 0xFF;
                if (a != 0) {
                    r = Std.int((r * 255) / a);
                    g = Std.int((g * 255) / a);
                    b = Std.int((b * 255) / a);
                }

                var l = noFma(r * 0.2125) + noFma(g * 0.7154) + noFma(b * 0.0721);
                pixels[row + x] = Std.int(l * (a / 255.0)) << 24;
            }
        }
    }

    /**
     * Returns `x` unchanged. Products passed through it cannot be fused with
     * the following addition into a multiply-add by the C++ compiler, which
     * would change the rounding (the reference is built without FMA).
     */
    @:noCompletion static function noFma(x:Float):Float {
        return x;
    }

    public inline function x():Int {
        return m_x;
    }

    public inline function y():Int {
        return m_y;
    }

    public inline function width():Int {
        return m_surface.width;
    }

    public inline function height():Int {
        return m_surface.height;
    }

    public function extents():Rect {
        return new Rect(m_x, m_y, width(), height());
    }

    public inline function surface():plutovg.Surface {
        return m_surface;
    }

    public inline function canvas():plutovg.Canvas {
        return m_canvas;
    }

}
