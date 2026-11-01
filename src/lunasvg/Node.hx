// Ported from lunasvg 3.5.0: include/lunasvg.h, source/lunasvg.cpp (Node, TextNode, Element)
// Original code Copyright (c) 2020-2026 Samuel Ugochukwu, licensed under MIT.
// Modified: translated from C++ to Haxe. See LICENSE.
package lunasvg;

import lunasvg.Graphics;
import lunasvg.SVGElement;
import lunasvg.SVGRenderState;

/**
 * A handle on a node of a document (`lunasvg::Node`): an element or a text
 * node. Handles are cheap: compare them with `equals()`.
 */
class Node {

    var m_node:Null<SVGNode>;

    function new(?node:SVGNode) {
        m_node = node;
    }

    public function isTextNode():Bool {
        return m_node != null && m_node.isTextNode();
    }

    public function isElement():Bool {
        return m_node != null && m_node.isElement();
    }

    public function toTextNode():TextNode {
        if (m_node != null && m_node.isTextNode())
            return new TextNode(cast m_node);
        return new TextNode();
    }

    public function toElement():Element {
        if (m_node != null && m_node.isElement())
            return new Element(cast m_node);
        return new Element();
    }

    public function parentElement():Element {
        if (m_node != null)
            return new Element(m_node.parentElement());
        return new Element();
    }

    public inline function isNull():Bool {
        return m_node == null;
    }

    public function equals(node:Node):Bool {
        return m_node == node.m_node;
    }

}

typedef NodeList = Array<Node>;

/**
 * A text node, child of a `<text>` or `<tspan>` element
 * (`lunasvg::TextNode`).
 */
class TextNode extends Node {

    @:allow(lunasvg)
    function new(?text:SVGTextNode) {
        super(text);
    }

    public function data():String {
        if (m_node != null)
            return text().data();
        return "";
    }

    public function setData(data:String):Void {
        if (m_node != null) {
            text().setData(data);
        }
    }

    inline function text():SVGTextNode {
        return cast m_node;
    }

}

/**
 * An element of a document (`lunasvg::Element`). Attributes can be read
 * and changed at runtime: the document is laid out again before the next
 * render.
 */
class Element extends Node {

    @:allow(lunasvg)
    function new(?element:SVGElement) {
        super(element);
    }

    public function hasAttribute(name:String):Bool {
        if (m_node != null)
            return element().hasAttributeByName(name);
        return false;
    }

    /**
     * The attribute value, or "" if it is not set.
     */
    public function getAttribute(name:String):String {
        if (m_node != null)
            return element().getAttributeByName(name);
        return "";
    }

    /**
     * Sets an attribute or a CSS property (`fill`, `stroke`, `color`,
     * `opacity`, `transform`, `d`...). It overrides style sheet rules.
     */
    public function setAttribute(name:String, value:String):Void {
        if (m_node != null) {
            element().setAttributeByName(name, value);
        }
    }

    /**
     * Renders this element into `bitmap`, with `matrix` mapping the
     * element's user space to the bitmap.
     */
    public function render(bitmap:Bitmap, ?matrix:Matrix):Void {
        if (m_node == null || bitmap.isNull())
            return;
        var canvas = Canvas.createFromBitmap(bitmap);
        var transform = matrix != null ? Transform.fromPublicMatrix(matrix) : new Transform();
        var state = new SVGRenderState(null, null, transform, Painting, canvas);
        element(true).render(state);
    }

    /**
     * Renders this element into a new bitmap fitting its bounding box. With
     * one size missing (-1), it is computed from the aspect ratio.
     * `backgroundColor` is a straight 0xRRGGBBAA color.
     */
    public function renderToBitmap(width:Int = -1, height:Int = -1, backgroundColor:Int = 0x00000000):Bitmap {
        if (m_node == null)
            return new Bitmap();
        var elementBounds = element(true).localTransform().mapRect(element().paintBoundingBox());
        if (elementBounds.isEmpty())
            return new Bitmap();
        if (width <= 0 && height <= 0) {
            width = Std.int(Math.fceil(elementBounds.w));
            height = Std.int(Math.fceil(elementBounds.h));
        } else if (width > 0 && height <= 0) {
            height = Std.int(Math.fceil(plutovg.Utils.f32(plutovg.Utils.f32(width * elementBounds.h) / elementBounds.w)));
        } else if (height > 0 && width <= 0) {
            width = Std.int(Math.fceil(plutovg.Utils.f32(plutovg.Utils.f32(height * elementBounds.w) / elementBounds.h)));
        }

        var xScale = plutovg.Utils.f32(width / elementBounds.w);
        var yScale = plutovg.Utils.f32(height / elementBounds.h);

        var matrix = new Matrix(xScale, 0, 0, yScale, -plutovg.Utils.f32(elementBounds.x * xScale), -plutovg.Utils.f32(elementBounds.y * yScale));
        var bitmap = Bitmap.create(width, height);
        if (backgroundColor != 0)
            bitmap.clear(backgroundColor);
        render(bitmap, matrix);
        return bitmap;
    }

    public function getLocalMatrix():Matrix {
        if (m_node != null)
            return Matrix.fromTransform(element(true).localTransform());
        return new Matrix();
    }

    public function getGlobalMatrix():Matrix {
        if (m_node == null)
            return new Matrix();
        var transform = element(true).localTransform();
        var parent = element().parentElement();
        while (parent != null) {
            transform.postMultiply(parent.localTransform());
            parent = parent.parentElement();
        }
        return Matrix.fromTransform(transform);
    }

    public function getLocalBoundingBox():Box {
        return getBoundingBox().transformed(getLocalMatrix());
    }

    public function getGlobalBoundingBox():Box {
        return getBoundingBox().transformed(getGlobalMatrix());
    }

    public function getBoundingBox():Box {
        if (m_node != null)
            return Box.fromRect(element(true).paintBoundingBox());
        return new Box();
    }

    public function children():NodeList {
        if (m_node == null)
            return [];
        var children:NodeList = [];
        for (child in element().children())
            children.push(wrap(child));
        return children;
    }

    static function wrap(node:SVGNode):Node {
        if (node.isElement())
            return new Element(cast node);
        return new TextNode(cast node);
    }

    function element(layoutIfNeeded:Bool = false):SVGElement {
        var element:SVGElement = cast m_node;
        if (element != null && layoutIfNeeded)
            element.rootElement().layoutIfNeeded();
        return element;
    }

}

typedef ElementList = Array<Element>;
