// Ported from lunasvg 3.5.0: source/svgelement.h, source/svgelement.cpp
// Original code Copyright (c) 2020-2026 Samuel Ugochukwu, licensed under MIT.
// Modified: translated from C++ to Haxe. See LICENSE.
package lunasvg;

import lunasvg.Graphics;
import lunasvg.SVGGeometryElement;
import lunasvg.SVGLayoutState;
import lunasvg.SVGPaintElement;
import lunasvg.SVGParserUtils;
import lunasvg.SVGProperty;
import lunasvg.SVGRenderState;
import lunasvg.SVGTextElement;
import plutovg.Utils.f32;

/**
 * A node of the SVG tree: an element or a text node (`SVGNode`).
 */
class SVGNode {

    var m_document:Document;

    var m_parentElement:Null<SVGElement> = null;

    public function new(document:Document) {
        m_document = document;
    }

    public function isTextNode():Bool {
        return false;
    }

    public function isElement():Bool {
        return false;
    }

    public function isPaintElement():Bool {
        return false;
    }

    public function isGraphicsElement():Bool {
        return false;
    }

    public function isGeometryElement():Bool {
        return false;
    }

    public function isTextContentElement():Bool {
        return false;
    }

    public function isTextPositioningElement():Bool {
        return false;
    }

    public inline function document():Document {
        return m_document;
    }

    public inline function rootElement():SVGRootElement {
        return m_document.m_rootElement;
    }

    public inline function parentElement():Null<SVGElement> {
        return m_parentElement;
    }

    public inline function setParentElement(parent:SVGElement):Void {
        m_parentElement = parent;
    }

    public inline function isRootElement():Bool {
        return m_parentElement == null;
    }

    public function clone(deep:Bool):SVGNode {
        throw "abstract";
    }

}

class SVGTextNode extends SVGNode {

    var m_data:String = "";

    public function new(document:Document) {
        super(document);
    }

    override public function isTextNode():Bool {
        return true;
    }

    public inline function data():String {
        return m_data;
    }

    public function setData(data:String):Void {
        rootElement().setNeedsLayout();
        m_data = data;
    }

    override public function clone(deep:Bool):SVGNode {
        var node = new SVGTextNode(document());
        node.setData(m_data);
        return node;
    }

}

class Attribute {

    var m_specificity:Int;

    var m_id:PropertyID;

    var m_value:String;

    public function new(specificity:Int, id:PropertyID, value:String) {
        m_specificity = specificity;
        m_id = id;
        m_value = value;
    }

    public inline function specificity():Int {
        return m_specificity;
    }

    public inline function id():PropertyID {
        return m_id;
    }

    public inline function value():String {
        return m_value;
    }

}

/**
 * Attributes, newest first (`std::forward_list` with `emplace_front`).
 */
typedef AttributeList = Array<Attribute>;

/**
 * Not an `enum abstract`: its values would shadow type names (`Color`,
 * `Transform`, `Rect`...) in every module importing it. Always qualify them.
 */
abstract ElementID(Int) from Int to Int {
    public static inline var Unknown:ElementID = cast 0;
    public static inline var Star:ElementID = cast 1;
    public static inline var Circle:ElementID = cast 2;
    public static inline var ClipPath:ElementID = cast 3;
    public static inline var Defs:ElementID = cast 4;
    public static inline var Ellipse:ElementID = cast 5;
    public static inline var G:ElementID = cast 6;
    public static inline var Image:ElementID = cast 7;
    public static inline var Line:ElementID = cast 8;
    public static inline var LinearGradient:ElementID = cast 9;
    public static inline var Marker:ElementID = cast 10;
    public static inline var Mask:ElementID = cast 11;
    public static inline var Path:ElementID = cast 12;
    public static inline var Pattern:ElementID = cast 13;
    public static inline var Polygon:ElementID = cast 14;
    public static inline var Polyline:ElementID = cast 15;
    public static inline var RadialGradient:ElementID = cast 16;
    public static inline var Rect:ElementID = cast 17;
    public static inline var Stop:ElementID = cast 18;
    public static inline var Style:ElementID = cast 19;
    public static inline var Svg:ElementID = cast 20;
    public static inline var Symbol:ElementID = cast 21;
    public static inline var Text:ElementID = cast 22;
    public static inline var Tspan:ElementID = cast 23;
    public static inline var Use:ElementID = cast 24;
}

typedef SVGNodeList = Array<SVGNode>;

typedef SVGPropertyList = Array<SVGProperty>;

class SVGElement extends SVGNode {

    static var elementTable:Null<Map<String, ElementID>> = null;

    /**
     * `elementid()`: the element id of a tag name.
     */
    public static function elementid(name:String):ElementID {
        if (elementTable == null) {
            var t = new Map<String, ElementID>();
            t.set("a", ElementID.G);
            t.set("circle", ElementID.Circle);
            t.set("clipPath", ElementID.ClipPath);
            t.set("defs", ElementID.Defs);
            t.set("ellipse", ElementID.Ellipse);
            t.set("g", ElementID.G);
            t.set("image", ElementID.Image);
            t.set("line", ElementID.Line);
            t.set("linearGradient", ElementID.LinearGradient);
            t.set("marker", ElementID.Marker);
            t.set("mask", ElementID.Mask);
            t.set("path", ElementID.Path);
            t.set("pattern", ElementID.Pattern);
            t.set("polygon", ElementID.Polygon);
            t.set("polyline", ElementID.Polyline);
            t.set("radialGradient", ElementID.RadialGradient);
            t.set("rect", ElementID.Rect);
            t.set("stop", ElementID.Stop);
            t.set("style", ElementID.Style);
            t.set("svg", ElementID.Svg);
            t.set("symbol", ElementID.Symbol);
            t.set("text", ElementID.Text);
            t.set("tspan", ElementID.Tspan);
            t.set("use", ElementID.Use);
            elementTable = t;
        }

        var id = elementTable.get(name);
        if (id == null)
            return ElementID.Unknown;
        return id;
    }

    public static function create(document:Document, id:ElementID):SVGElement {
        switch (id) {
            case ElementID.Svg:
                return new SVGSVGElement(document);
            case ElementID.Path:
                return new SVGPathElement(document);
            case ElementID.G:
                return new SVGGElement(document);
            case ElementID.Rect:
                return new SVGRectElement(document);
            case ElementID.Circle:
                return new SVGCircleElement(document);
            case ElementID.Ellipse:
                return new SVGEllipseElement(document);
            case ElementID.Line:
                return new SVGLineElement(document);
            case ElementID.Defs:
                return new SVGDefsElement(document);
            case ElementID.Polygon | ElementID.Polyline:
                return new SVGPolyElement(document, id);
            case ElementID.Stop:
                return new SVGStopElement(document);
            case ElementID.LinearGradient:
                return new SVGLinearGradientElement(document);
            case ElementID.RadialGradient:
                return new SVGRadialGradientElement(document);
            case ElementID.Symbol:
                return new SVGSymbolElement(document);
            case ElementID.Use:
                return new SVGUseElement(document);
            case ElementID.Pattern:
                return new SVGPatternElement(document);
            case ElementID.Mask:
                return new SVGMaskElement(document);
            case ElementID.ClipPath:
                return new SVGClipPathElement(document);
            case ElementID.Marker:
                return new SVGMarkerElement(document);
            case ElementID.Image:
                return new SVGImageElement(document);
            case ElementID.Style:
                return new SVGStyleElement(document);
            case ElementID.Text:
                return new SVGTextElement(document);
            case ElementID.Tspan:
                return new SVGTSpanElement(document);
            default:
                throw 'unexpected element id $id';
        }
    }

    var m_paintBoundingBox:lunasvg.Graphics.Rect = lunasvg.Graphics.Rect.invalid();

    var m_clipper:Null<SVGClipPathElement> = null;

    var m_masker:Null<SVGMaskElement> = null;

    var m_opacity:Float = 1;

    var m_font_size:Float = 12;

    var m_display:lunasvg.SVGProperty.Display = Inline;

    var m_overflow:lunasvg.SVGProperty.Overflow = Visible;

    var m_visibility:lunasvg.SVGProperty.Visibility = Visible;

    var m_pointer_events:PointerEvents = Auto;

    var m_id:ElementID;

    var m_attributes:AttributeList = [];

    var m_properties:SVGPropertyList = [];

    var m_children:SVGNodeList = [];

    public function new(document:Document, id:ElementID) {
        super(document);
        m_id = id;
    }

    public function hasAttributeByName(name:String):Bool {
        var id = PropertyIds.propertyid(name);
        if (id == PropertyID.Unknown)
            return false;
        return hasAttribute(id);
    }

    public function getAttributeByName(name:String):String {
        var id = PropertyIds.propertyid(name);
        if (id == PropertyID.Unknown)
            return "";
        return getAttribute(id);
    }

    public function setAttributeByName(name:String, value:String):Bool {
        var id = PropertyIds.propertyid(name);
        if (id == PropertyID.Unknown)
            return false;
        return setAttribute(0x1000, id, value);
    }

    public function findAttribute(id:PropertyID):Null<Attribute> {
        for (attribute in m_attributes) {
            if (id == attribute.id()) {
                return attribute;
            }
        }

        return null;
    }

    public function hasAttribute(id:PropertyID):Bool {
        for (attribute in m_attributes) {
            if (id == attribute.id()) {
                return true;
            }
        }

        return false;
    }

    public function getAttribute(id:PropertyID):String {
        for (attribute in m_attributes) {
            if (id == attribute.id()) {
                return attribute.value();
            }
        }

        return "";
    }

    public function setAttribute(specificity:Int, id:PropertyID, value:String):Bool {
        for (i in 0...m_attributes.length) {
            var attribute = m_attributes[i];
            if (id == attribute.id()) {
                if (specificity < attribute.specificity())
                    return false;
                parseAttribute(id, value);
                m_attributes[i] = new Attribute(specificity, id, value);
                return true;
            }
        }

        parseAttribute(id, value);
        m_attributes.unshift(new Attribute(specificity, id, value));
        return true;
    }

    public function setAttributes(attributes:AttributeList):Void {
        for (attribute in attributes.copy()) {
            setAttributeFrom(attribute);
        }
    }

    public function setAttributeFrom(attribute:Attribute):Bool {
        return setAttribute(attribute.specificity(), attribute.id(), attribute.value());
    }

    public function parseAttribute(id:PropertyID, value:String):Void {
        rootElement().setNeedsLayout();
        var property = getProperty(id);
        if (property != null) {
            property.parse(new StringView(value));
        }
    }

    public function previousElement():Null<SVGElement> {
        var parent = parentElement();
        if (parent == null)
            return null;
        var element:Null<SVGElement> = null;
        for (node in parent.children()) {
            if (node.isTextNode())
                continue;
            if (node == this)
                return element;
            element = cast node;
        }

        return null;
    }

    public function nextElement():Null<SVGElement> {
        var parent = parentElement();
        if (parent == null)
            return null;
        var children = parent.children();
        var element:Null<SVGElement> = null;
        var i = children.length - 1;
        while (i >= 0) {
            var node = children[i--];
            if (node.isTextNode())
                continue;
            if (node == this)
                return element;
            element = cast node;
        }

        return null;
    }

    public function addChild(child:SVGNode):SVGNode {
        child.setParentElement(this);
        m_children.push(child);
        return child;
    }

    public function firstChild():Null<SVGNode> {
        if (m_children.length == 0)
            return null;
        return m_children[0];
    }

    public function lastChild():Null<SVGNode> {
        if (m_children.length == 0)
            return null;
        return m_children[m_children.length - 1];
    }

    public inline function id():ElementID {
        return m_id;
    }

    public inline function attributes():AttributeList {
        return m_attributes;
    }

    public inline function properties():SVGPropertyList {
        return m_properties;
    }

    public inline function children():SVGNodeList {
        return m_children;
    }

    /**
     * The transform from this element's user space to its parent's (a new
     * instance, safe to change).
     */
    public function localTransform():Transform {
        return Transform.identity();
    }

    public function fillBoundingBox():lunasvg.Graphics.Rect {
        var fillBoundingBox = lunasvg.Graphics.Rect.invalid();
        for (child in m_children) {
            var element = toSVGElement(child);
            if (element != null && !element.isHiddenElement()) {
                fillBoundingBox.unite(element.localTransform().mapRect(element.fillBoundingBox()));
            }
        }

        if (!fillBoundingBox.isValid())
            fillBoundingBox = lunasvg.Graphics.Rect.empty();
        return fillBoundingBox;
    }

    public function strokeBoundingBox():lunasvg.Graphics.Rect {
        var strokeBoundingBox = lunasvg.Graphics.Rect.invalid();
        for (child in m_children) {
            var element = toSVGElement(child);
            if (element != null && !element.isHiddenElement()) {
                strokeBoundingBox.unite(element.localTransform().mapRect(element.strokeBoundingBox()));
            }
        }

        if (!strokeBoundingBox.isValid())
            strokeBoundingBox = lunasvg.Graphics.Rect.empty();
        return strokeBoundingBox;
    }

    public function paintBoundingBox():lunasvg.Graphics.Rect {
        if (m_paintBoundingBox.isValid())
            return m_paintBoundingBox.clone();
        m_paintBoundingBox = lunasvg.Graphics.Rect.empty();
        m_paintBoundingBox = strokeBoundingBox();
        if (m_clipper != null)
            m_paintBoundingBox.intersect(m_clipper.clipBoundingBox(this));
        if (m_masker != null)
            m_paintBoundingBox.intersect(m_masker.maskBoundingBox(this));
        return m_paintBoundingBox.clone();
    }

    public function getMarker(id:String):Null<SVGMarkerElement> {
        var element = rootElement().getElementById(id);
        if (element != null && element.id() == ElementID.Marker)
            return cast element;
        return null;
    }

    public function getClipper(id:String):Null<SVGClipPathElement> {
        var element = rootElement().getElementById(id);
        if (element != null && element.id() == ElementID.ClipPath)
            return cast element;
        return null;
    }

    public function getMasker(id:String):Null<SVGMaskElement> {
        var element = rootElement().getElementById(id);
        if (element != null && element.id() == ElementID.Mask)
            return cast element;
        return null;
    }

    public function getPainter(id:String):Null<SVGPaintElement> {
        var element = rootElement().getElementById(id);
        if (element != null && element.isPaintElement())
            return cast element;
        return null;
    }

    public function elementFromPoint(x:Float, y:Float):Null<SVGElement> {
        var i = m_children.length - 1;
        while (i >= 0) {
            var child = toSVGElement(m_children[i--]);
            if (child != null && !child.isHiddenElement()) {
                var element = child.elementFromPoint(x, y);
                if (element != null) {
                    return element;
                }
            }
        }

        if (isPointableElement()) {
            var transform = localTransform();
            var parent = parentElement();
            while (parent != null) {
                transform.postMultiply(parent.localTransform());
                parent = parent.parentElement();
            }
            var bbox = transform.mapRect(paintBoundingBox());
            if (bbox.contains(x, y)) {
                return this;
            }
        }

        return null;
    }

    /**
     * Calls `callback` on this element and all its descendant elements.
     */
    public function transverse(callback:SVGElement->Void):Void {
        callback(this);
        for (child in m_children) {
            var element = toSVGElement(child);
            if (element != null) {
                element.transverse(callback);
            }
        }
    }

    public function addProperty(value:SVGProperty):Void {
        m_properties.unshift(value);
    }

    public function getProperty(id:PropertyID):Null<SVGProperty> {
        for (property in m_properties) {
            if (id == property.id()) {
                return property;
            }
        }

        return null;
    }

    public function currentViewportSize():Size {
        var parent = parentElement();
        if (parent == null) {
            var element:SVGSVGElement = cast this;
            var viewBox = element.viewBox();
            if (viewBox.value().isValid())
                return viewBox.value().size();
            return new Size(300, 150);
        }

        if (parent.id() == ElementID.Svg) {
            var element:SVGSVGElement = cast parent;
            var viewBox = element.viewBox();
            if (viewBox.value().isValid())
                return viewBox.value().size();
            var lengthContext = new LengthContext(element);
            var width = lengthContext.valueForSVGLength(element.width());
            var height = lengthContext.valueForSVGLength(element.height());
            return new Size(width, height);
        }

        return parent.currentViewportSize();
    }

    public inline function fontSize():Float {
        return m_font_size;
    }

    public function cloneChildren(parentElement:SVGElement):Void {
        for (child in m_children) {
            parentElement.addChild(child.clone(true));
        }
    }

    override public function clone(deep:Bool):SVGNode {
        var element = SVGElement.create(document(), m_id);
        element.setAttributes(m_attributes);
        if (deep) {
            cloneChildren(element);
        }
        return element;
    }

    public function build():Void {
        for (child in m_children) {
            var element = toSVGElement(child);
            if (element != null) {
                element.build();
            }
        }
    }

    public function layoutElement(state:SVGLayoutState):Void {
        m_paintBoundingBox = lunasvg.Graphics.Rect.invalid();
        m_clipper = getClipper(state.clipPath());
        m_masker = getMasker(state.mask());
        m_opacity = state.opacity();

        m_font_size = state.fontSize();
        m_display = state.display();
        m_overflow = state.overflow();
        m_visibility = state.visibility();
        m_pointer_events = state.pointerEvents();
    }

    public function layoutChildren(state:SVGLayoutState):Void {
        for (child in m_children) {
            var element = toSVGElement(child);
            if (element != null) {
                element.layout(state);
            }
        }
    }

    public function layout(state:SVGLayoutState):Void {
        var newState = SVGLayoutState.child(state, this);
        layoutElement(newState);
        layoutChildren(newState);
    }

    public function renderChildren(state:SVGRenderState):Void {
        for (child in m_children) {
            var element = toSVGElement(child);
            if (element != null) {
                element.render(state);
            }
        }
    }

    public function render(state:SVGRenderState):Void {}

    public inline function isDisplayNone():Bool {
        return m_display == lunasvg.SVGProperty.Display.None;
    }

    public inline function isOverflowHidden():Bool {
        return m_overflow == lunasvg.SVGProperty.Overflow.Hidden;
    }

    public inline function isVisibilityHidden():Bool {
        return m_visibility != lunasvg.SVGProperty.Visibility.Visible;
    }

    public function isHiddenElement():Bool {
        if (isDisplayNone())
            return true;
        switch (m_id) {
            case ElementID.Defs | ElementID.Symbol | ElementID.Marker | ElementID.ClipPath | ElementID.Mask | ElementID.LinearGradient
                | ElementID.RadialGradient | ElementID.Pattern | ElementID.Stop:
                return true;
            default:
                return false;
        }
    }

    public function isPointableElement():Bool {
        if (m_pointer_events != PointerEvents.None
            && m_visibility != lunasvg.SVGProperty.Visibility.Hidden
            && m_display != lunasvg.SVGProperty.Display.None
            && m_opacity != 0) {
            switch (m_id) {
                case ElementID.Line | ElementID.Rect | ElementID.Ellipse | ElementID.Circle | ElementID.Polyline | ElementID.Polygon
                    | ElementID.Path | ElementID.Text | ElementID.Image:
                    return true;
                default:
            }
        }

        return false;
    }

    public inline function clipper():Null<SVGClipPathElement> {
        return m_clipper;
    }

    public inline function masker():Null<SVGMaskElement> {
        return m_masker;
    }

    public inline function opacity():Float {
        return m_opacity;
    }

    override public function isElement():Bool {
        return true;
    }

    public static inline function toSVGElement(node:Null<SVGNode>):Null<SVGElement> {
        if (node != null && node.isElement())
            return cast node;
        return null;
    }

}

class SVGStyleElement extends SVGElement {

    public function new(document:Document) {
        super(document, ElementID.Style);
    }

}

/**
 * The `viewBox` and `preserveAspectRatio` attributes of an element
 * (`SVGFitToViewBox`, a C++ base class held here as a member).
 */
class SVGFitToViewBox {

    var m_viewBox:SVGRect;

    var m_preserveAspectRatio:SVGPreserveAspectRatio;

    public function new(element:SVGElement) {
        m_viewBox = new SVGRect(PropertyID.ViewBox);
        m_preserveAspectRatio = new SVGPreserveAspectRatio(PropertyID.PreserveAspectRatio);
        element.addProperty(m_viewBox);
        element.addProperty(m_preserveAspectRatio);
    }

    public inline function viewBox():SVGRect {
        return m_viewBox;
    }

    public inline function preserveAspectRatio():SVGPreserveAspectRatio {
        return m_preserveAspectRatio;
    }

    public function viewBoxToViewTransform(viewportSize:Size):Transform {
        var viewBoxRect = m_viewBox.value();
        if (viewBoxRect.isEmpty() || viewportSize.isEmpty())
            return Transform.identity();
        return m_preserveAspectRatio.getTransform(viewBoxRect, viewportSize);
    }

    public function getClipRect(viewportSize:Size):lunasvg.Graphics.Rect {
        var viewBoxRect = m_viewBox.value();
        if (viewBoxRect.isEmpty() || viewportSize.isEmpty())
            return new lunasvg.Graphics.Rect(0, 0, viewportSize.w, viewportSize.h);
        return m_preserveAspectRatio.getClipRect(viewBoxRect, viewportSize);
    }

}

/**
 * The `href` attribute of an element (`SVGURIReference`, a C++ base class
 * held here as a member).
 */
class SVGURIReference {

    var m_href:SVGString;

    public function new(element:SVGElement) {
        m_href = new SVGString(PropertyID.Href);
        element.addProperty(m_href);
    }

    public inline function href():SVGString {
        return m_href;
    }

    public inline function hrefString():String {
        return m_href.value();
    }

    public function getTargetElement(document:Document):Null<SVGElement> {
        var value = m_href.value();
        if (value.length == 0 || StringTools.fastCodeAt(value, 0) != '#'.code)
            return null;
        return document.m_rootElement.getElementById(value.substr(1));
    }

}

class SVGPaintServer {

    var m_element:Null<SVGPaintElement>;

    var m_color:lunasvg.Graphics.Color;

    var m_opacity:Float;

    public function new(?element:SVGPaintElement, ?color:lunasvg.Graphics.Color, opacity:Float = 0) {
        m_element = element;
        m_color = color != null ? color : lunasvg.Graphics.Color.Transparent;
        m_opacity = f32(opacity);
    }

    public inline function isRenderable():Bool {
        return m_opacity > 0 && (m_element != null || m_color.alpha() > 0);
    }

    public inline function element():Null<SVGPaintElement> {
        return m_element;
    }

    public inline function color():lunasvg.Graphics.Color {
        return m_color;
    }

    public inline function opacity():Float {
        return m_opacity;
    }

    public function applyPaint(state:SVGRenderState):Bool {
        if (!isRenderable())
            return false;
        if (m_element != null)
            return m_element.applyPaint(state, m_opacity);
        state.canvas().setColor(m_color.colorWithAlpha(m_opacity));
        return true;
    }

}

class SVGGraphicsElement extends SVGElement {

    var m_transform:SVGTransform;

    public function new(document:Document, id:ElementID) {
        super(document, id);
        m_transform = new SVGTransform(PropertyID.Transform);
        addProperty(m_transform);
    }

    override public function isGraphicsElement():Bool {
        return true;
    }

    public inline function transform():SVGTransform {
        return m_transform;
    }

    override public function localTransform():Transform {
        return m_transform.value().clone();
    }

    public function getPaintServer(paint:lunasvg.SVGProperty.Paint, opacity:Float):SVGPaintServer {
        if (paint.isNone())
            return new SVGPaintServer();
        var element = getPainter(paint.id());
        if (element != null)
            return new SVGPaintServer(element, paint.color(), opacity);
        return new SVGPaintServer(null, paint.color(), opacity);
    }

    public function getStrokeData(state:SVGLayoutState):StrokeData {
        var lengthContext = new LengthContext(this);
        var strokeData = new StrokeData(lengthContext.valueForLength(state.strokeWidth(), Diagonal));
        strokeData.setMiterLimit(state.strokeMiterlimit());
        strokeData.setLineCap(state.strokeLinecap());
        strokeData.setLineJoin(state.strokeLinejoin());
        strokeData.setDashOffset(lengthContext.valueForLength(state.strokeDashoffset(), Diagonal));

        var dashArray:DashArray = [];
        for (dash in state.strokeDasharray())
            dashArray.push(lengthContext.valueForLength(dash, Diagonal));
        strokeData.setDashArray(dashArray);
        return strokeData;
    }

}

class SVGSVGElement extends SVGGraphicsElement {

    var m_fitToViewBox:SVGFitToViewBox;

    var m_x:SVGLength;

    var m_y:SVGLength;

    var m_width:SVGLength;

    var m_height:SVGLength;

    public function new(document:Document) {
        super(document, ElementID.Svg);
        m_fitToViewBox = new SVGFitToViewBox(this);
        m_x = new SVGLength(PropertyID.X, Horizontal, Allow, 0, None);
        m_y = new SVGLength(PropertyID.Y, Vertical, Allow, 0, None);
        m_width = new SVGLength(PropertyID.Width, Horizontal, Forbid, 100, Percent);
        m_height = new SVGLength(PropertyID.Height, Vertical, Forbid, 100, Percent);
        addProperty(m_x);
        addProperty(m_y);
        addProperty(m_width);
        addProperty(m_height);
    }

    public inline function x():SVGLength {
        return m_x;
    }

    public inline function y():SVGLength {
        return m_y;
    }

    public inline function width():SVGLength {
        return m_width;
    }

    public inline function height():SVGLength {
        return m_height;
    }

    public inline function viewBox():SVGRect {
        return m_fitToViewBox.viewBox();
    }

    public inline function preserveAspectRatio():SVGPreserveAspectRatio {
        return m_fitToViewBox.preserveAspectRatio();
    }

    public inline function viewBoxToViewTransform(viewportSize:Size):Transform {
        return m_fitToViewBox.viewBoxToViewTransform(viewportSize);
    }

    public inline function getClipRect(viewportSize:Size):lunasvg.Graphics.Rect {
        return m_fitToViewBox.getClipRect(viewportSize);
    }

    override public function localTransform():Transform {
        var lengthContext = new LengthContext(this);
        var viewportRect = new lunasvg.Graphics.Rect(
            lengthContext.valueForSVGLength(m_x),
            lengthContext.valueForSVGLength(m_y),
            lengthContext.valueForSVGLength(m_width),
            lengthContext.valueForSVGLength(m_height)
        );

        if (isRootElement())
            return viewBoxToViewTransform(viewportRect.size());
        return super.localTransform().mul(Transform.translated(viewportRect.x, viewportRect.y)).mul(viewBoxToViewTransform(viewportRect.size()));
    }

    override public function render(state:SVGRenderState):Void {
        if (isDisplayNone())
            return;
        var lengthContext = new LengthContext(this);
        var viewportSize = new Size(
            lengthContext.valueForSVGLength(m_width),
            lengthContext.valueForSVGLength(m_height)
        );

        if (viewportSize.isEmpty())
            return;
        var blendInfo = SVGBlendInfo.of(this);
        var newState = SVGRenderState.child(this, state, localTransform());
        newState.beginGroup(blendInfo);
        if (isOverflowHidden())
            newState.canvas().clipRect(getClipRect(viewportSize), NonZero, newState.currentTransform());
        renderChildren(newState);
        newState.endGroup(blendInfo);
    }

}

class SVGRootElement extends SVGSVGElement {

    var m_idCache:Map<String, SVGElement> = new Map();

    var m_intrinsicWidth:Float = -1;

    var m_intrinsicHeight:Float = -1;

    public function new(document:Document) {
        super(document);
    }

    public inline function intrinsicWidth():Float {
        return m_intrinsicWidth;
    }

    public inline function intrinsicHeight():Float {
        return m_intrinsicHeight;
    }

    public inline function setNeedsLayout():Void {
        m_intrinsicWidth = -1;
    }

    public inline function needsLayout():Bool {
        return m_intrinsicWidth == -1;
    }

    public function layoutIfNeeded():SVGRootElement {
        if (needsLayout())
            forceLayout();
        return this;
    }

    public function getElementById(id:String):Null<SVGElement> {
        return m_idCache.get(id);
    }

    /**
     * Registers `element` under `id` (`std::map::emplace`: an existing
     * entry is kept).
     */
    public function addElementById(id:String, element:SVGElement):Void {
        if (!m_idCache.exists(id))
            m_idCache.set(id, element);
    }

    override public function layout(state:SVGLayoutState):Void {
        super.layout(state);

        var lengthContext = new LengthContext(this);
        if (!width().isPercent()) {
            m_intrinsicWidth = lengthContext.valueForSVGLength(width());
        } else {
            m_intrinsicWidth = 0;
        }

        if (!height().isPercent()) {
            m_intrinsicHeight = lengthContext.valueForSVGLength(height());
        } else {
            m_intrinsicHeight = 0;
        }

        var viewBoxRect = viewBox().value();
        if (!viewBoxRect.isEmpty() && (m_intrinsicWidth == 0 || m_intrinsicHeight == 0)) {
            var intrinsicRatio = f32(viewBoxRect.w / viewBoxRect.h);
            if (m_intrinsicWidth == 0 && m_intrinsicHeight != 0)
                m_intrinsicWidth = f32(m_intrinsicHeight * intrinsicRatio);
            else if (m_intrinsicWidth != 0 && m_intrinsicHeight == 0) {
                m_intrinsicHeight = f32(m_intrinsicWidth / intrinsicRatio);
            }
        }

        if (viewBoxRect.isValid() && (m_intrinsicWidth == 0 || m_intrinsicHeight == 0)) {
            m_intrinsicWidth = viewBoxRect.w;
            m_intrinsicHeight = viewBoxRect.h;
        }

        if (m_intrinsicWidth == 0 || m_intrinsicHeight == 0) {
            var boundingBox = paintBoundingBox();
            if (m_intrinsicWidth == 0)
                m_intrinsicWidth = boundingBox.right();
            if (m_intrinsicHeight == 0) {
                m_intrinsicHeight = boundingBox.bottom();
            }
        }
    }

    public function forceLayout():Void {
        var state = new SVGLayoutState();
        layout(state);
    }

}

class SVGUseElement extends SVGGraphicsElement {

    var m_uriReference:SVGURIReference;

    var m_x:SVGLength;

    var m_y:SVGLength;

    var m_width:SVGLength;

    var m_height:SVGLength;

    public function new(document:Document) {
        super(document, ElementID.Use);
        m_uriReference = new SVGURIReference(this);
        m_x = new SVGLength(PropertyID.X, Horizontal, Allow, 0, None);
        m_y = new SVGLength(PropertyID.Y, Vertical, Allow, 0, None);
        m_width = new SVGLength(PropertyID.Width, Horizontal, Forbid, 100, Percent);
        m_height = new SVGLength(PropertyID.Height, Vertical, Forbid, 100, Percent);
        addProperty(m_x);
        addProperty(m_y);
        addProperty(m_width);
        addProperty(m_height);
    }

    public inline function x():SVGLength {
        return m_x;
    }

    public inline function y():SVGLength {
        return m_y;
    }

    public inline function width():SVGLength {
        return m_width;
    }

    public inline function height():SVGLength {
        return m_height;
    }

    public inline function getTargetElement(document:Document):Null<SVGElement> {
        return m_uriReference.getTargetElement(document);
    }

    override public function localTransform():Transform {
        var lengthContext = new LengthContext(this);
        var translation = new Point(
            lengthContext.valueForSVGLength(m_x),
            lengthContext.valueForSVGLength(m_y)
        );

        return super.localTransform().mul(Transform.translated(translation.x, translation.y));
    }

    override public function render(state:SVGRenderState):Void {
        if (isDisplayNone())
            return;
        var blendInfo = SVGBlendInfo.of(this);
        var newState = SVGRenderState.child(this, state, localTransform());
        newState.beginGroup(blendInfo);
        renderChildren(newState);
        newState.endGroup(blendInfo);
    }

    override public function build():Void {
        var targetElement = getTargetElement(document());
        if (targetElement != null) {
            var newElement = cloneTargetElement(targetElement);
            if (newElement != null) {
                addChild(newElement);
            }
        }

        super.build();
    }

    static function isDisallowedElement(element:SVGElement):Bool {
        switch (element.id()) {
            case ElementID.Circle | ElementID.Ellipse | ElementID.G | ElementID.Image | ElementID.Line | ElementID.Path | ElementID.Polygon
                | ElementID.Polyline | ElementID.Rect | ElementID.Svg | ElementID.Symbol | ElementID.Text | ElementID.Tspan | ElementID.Use:
                return false;
            default:
                return true;
        }
    }

    function cloneTargetElement(targetElement:SVGElement):Null<SVGElement> {
        if (targetElement == this || isDisallowedElement(targetElement))
            return null;
        var idAttr = targetElement.getAttribute(PropertyID.Id);
        var parent = parentElement();
        while (parent != null) {
            var attribute = parent.findAttribute(PropertyID.Id);
            if (attribute != null && idAttr == attribute.value())
                return null;
            parent = parent.parentElement();
        }

        var tagId = targetElement.id();
        if (tagId == ElementID.Symbol) {
            tagId = ElementID.Svg;
        }

        var newElement = SVGElement.create(document(), tagId);
        newElement.setAttributes(targetElement.attributes());
        if (newElement.id() == ElementID.Svg) {
            for (attribute in attributes().copy()) {
                if (attribute.id() == PropertyID.Width || attribute.id() == PropertyID.Height) {
                    newElement.setAttributeFrom(attribute);
                }
            }
        }

        if (newElement.id() != ElementID.Use)
            targetElement.cloneChildren(newElement);
        return newElement;
    }

}

class SVGImageElement extends SVGGraphicsElement {

    var m_x:SVGLength;

    var m_y:SVGLength;

    var m_width:SVGLength;

    var m_height:SVGLength;

    var m_preserveAspectRatio:SVGPreserveAspectRatio;

    var m_image:Bitmap = new Bitmap();

    public function new(document:Document) {
        super(document, ElementID.Image);
        m_x = new SVGLength(PropertyID.X, Horizontal, Allow, 0, None);
        m_y = new SVGLength(PropertyID.Y, Vertical, Allow, 0, None);
        m_width = new SVGLength(PropertyID.Width, Horizontal, Forbid, 100, Percent);
        m_height = new SVGLength(PropertyID.Height, Vertical, Forbid, 100, Percent);
        m_preserveAspectRatio = new SVGPreserveAspectRatio(PropertyID.PreserveAspectRatio);
        addProperty(m_x);
        addProperty(m_y);
        addProperty(m_width);
        addProperty(m_height);
        addProperty(m_preserveAspectRatio);
    }

    public inline function x():SVGLength {
        return m_x;
    }

    public inline function y():SVGLength {
        return m_y;
    }

    public inline function width():SVGLength {
        return m_width;
    }

    public inline function height():SVGLength {
        return m_height;
    }

    public inline function preserveAspectRatio():SVGPreserveAspectRatio {
        return m_preserveAspectRatio;
    }

    public inline function image():Bitmap {
        return m_image;
    }

    override public function fillBoundingBox():lunasvg.Graphics.Rect {
        var lengthContext = new LengthContext(this);
        var viewportRect = new lunasvg.Graphics.Rect(
            lengthContext.valueForSVGLength(m_x),
            lengthContext.valueForSVGLength(m_y),
            lengthContext.valueForSVGLength(m_width),
            lengthContext.valueForSVGLength(m_height)
        );

        return viewportRect;
    }

    override public function strokeBoundingBox():lunasvg.Graphics.Rect {
        return fillBoundingBox();
    }

    override public function render(state:SVGRenderState):Void {
        if (m_image.isNull() || isDisplayNone() || isVisibilityHidden())
            return;
        var dstRect = fillBoundingBox();
        var srcRect = new lunasvg.Graphics.Rect(0, 0, m_image.width(), m_image.height());
        if (dstRect.isEmpty() || srcRect.isEmpty())
            return;
        m_preserveAspectRatio.transformRect(dstRect, srcRect);

        var blendInfo = SVGBlendInfo.of(this);
        var newState = SVGRenderState.child(this, state, localTransform());
        newState.beginGroup(blendInfo);
        newState.canvas().drawImage(m_image, dstRect, srcRect, newState.currentTransform());
        newState.endGroup(blendInfo);
    }

    static function loadImageResource(href:String):Bitmap {
        if (StringTools.startsWith(href, "data:")) {
            var index = href.indexOf(",", 5);
            if (index < 0)
                return new Bitmap();
            return Lunasvg.decodeImageBase64(href.substr(index + 1));
        }

        return Lunasvg.loadImageFile(href);
    }

    override public function parseAttribute(id:PropertyID, value:String):Void {
        if (id == PropertyID.Href) {
            m_image = loadImageResource(value);
        } else {
            super.parseAttribute(id, value);
        }
    }

}

class SVGSymbolElement extends SVGGraphicsElement {

    var m_fitToViewBox:SVGFitToViewBox;

    public function new(document:Document) {
        super(document, ElementID.Symbol);
        m_fitToViewBox = new SVGFitToViewBox(this);
    }

    public inline function viewBox():SVGRect {
        return m_fitToViewBox.viewBox();
    }

    public inline function preserveAspectRatio():SVGPreserveAspectRatio {
        return m_fitToViewBox.preserveAspectRatio();
    }

}

class SVGGElement extends SVGGraphicsElement {

    public function new(document:Document) {
        super(document, ElementID.G);
    }

    override public function render(state:SVGRenderState):Void {
        if (isDisplayNone())
            return;
        var blendInfo = SVGBlendInfo.of(this);
        var newState = SVGRenderState.child(this, state, localTransform());
        newState.beginGroup(blendInfo);
        renderChildren(newState);
        newState.endGroup(blendInfo);
    }

}

class SVGDefsElement extends SVGGraphicsElement {

    public function new(document:Document) {
        super(document, ElementID.Defs);
    }

}

class SVGMarkerElement extends SVGElement {

    var m_fitToViewBox:SVGFitToViewBox;

    var m_refX:SVGLength;

    var m_refY:SVGLength;

    var m_markerWidth:SVGLength;

    var m_markerHeight:SVGLength;

    var m_markerUnits:SVGEnumeration;

    var m_orient:SVGAngle;

    public function new(document:Document) {
        super(document, ElementID.Marker);
        m_fitToViewBox = new SVGFitToViewBox(this);
        m_refX = new SVGLength(PropertyID.RefX, Horizontal, Allow, 0, None);
        m_refY = new SVGLength(PropertyID.RefY, Vertical, Allow, 0, None);
        m_markerWidth = new SVGLength(PropertyID.MarkerWidth, Horizontal, Forbid, 3, None);
        m_markerHeight = new SVGLength(PropertyID.MarkerHeight, Vertical, Forbid, 3, None);
        m_markerUnits = new SVGEnumeration(PropertyID.MarkerUnits, (MarkerUnits.StrokeWidth : Int), SVGEnumeration.MARKER_UNITS_ENTRIES);
        m_orient = new SVGAngle(PropertyID.Orient);
        addProperty(m_refX);
        addProperty(m_refY);
        addProperty(m_markerWidth);
        addProperty(m_markerHeight);
        addProperty(m_markerUnits);
        addProperty(m_orient);
    }

    public inline function refX():SVGLength {
        return m_refX;
    }

    public inline function refY():SVGLength {
        return m_refY;
    }

    public inline function markerWidth():SVGLength {
        return m_markerWidth;
    }

    public inline function markerHeight():SVGLength {
        return m_markerHeight;
    }

    public inline function markerUnits():SVGEnumeration {
        return m_markerUnits;
    }

    public inline function orient():SVGAngle {
        return m_orient;
    }

    public inline function viewBox():SVGRect {
        return m_fitToViewBox.viewBox();
    }

    public inline function viewBoxToViewTransform(viewportSize:Size):Transform {
        return m_fitToViewBox.viewBoxToViewTransform(viewportSize);
    }

    public inline function getClipRect(viewportSize:Size):lunasvg.Graphics.Rect {
        return m_fitToViewBox.getClipRect(viewportSize);
    }

    public function refPoint():Point {
        var lengthContext = new LengthContext(this);
        var refPoint = new Point(
            lengthContext.valueForSVGLength(m_refX),
            lengthContext.valueForSVGLength(m_refY)
        );

        return refPoint;
    }

    public function markerSize():Size {
        var lengthContext = new LengthContext(this);
        var markerSize = new Size(
            lengthContext.valueForSVGLength(m_markerWidth),
            lengthContext.valueForSVGLength(m_markerHeight)
        );

        return markerSize;
    }

    public function markerTransform(origin:Point, angle:Float, strokeWidth:Float):Transform {
        var transform = Transform.translated(origin.x, origin.y);
        if (m_orient.orientType() == OrientType.Angle) {
            transform.rotate(m_orient.value());
        } else {
            transform.rotate(angle);
        }

        var viewTransform = viewBoxToViewTransform(markerSize());
        var ref = refPoint();
        var refOrigin = viewTransform.mapPoint(ref.x, ref.y);
        if (m_markerUnits.value() == (MarkerUnits.StrokeWidth : Int))
            transform.scale(strokeWidth, strokeWidth);
        transform.translate(-refOrigin.x, -refOrigin.y);
        return transform.mul(viewTransform);
    }

    public function markerBoundingBox(origin:Point, angle:Float, strokeWidth:Float):lunasvg.Graphics.Rect {
        return markerTransform(origin, angle, strokeWidth).mapRect(paintBoundingBox());
    }

    public function renderMarker(state:SVGRenderState, origin:Point, angle:Float, strokeWidth:Float):Void {
        if (state.hasCycleReference(this))
            return;
        var blendInfo = SVGBlendInfo.of(this);
        var newState = SVGRenderState.child(this, state, markerTransform(origin, angle, strokeWidth));
        newState.beginGroup(blendInfo);
        if (isOverflowHidden())
            newState.canvas().clipRect(getClipRect(markerSize()), NonZero, newState.currentTransform());
        renderChildren(newState);
        newState.endGroup(blendInfo);
    }

    override public function localTransform():Transform {
        return viewBoxToViewTransform(markerSize());
    }

}

class SVGClipPathElement extends SVGGraphicsElement {

    var m_clipPathUnits:SVGEnumeration;

    public function new(document:Document) {
        super(document, ElementID.ClipPath);
        m_clipPathUnits = new SVGEnumeration(PropertyID.ClipPathUnits, (Units.UserSpaceOnUse : Int), SVGEnumeration.UNITS_ENTRIES);
        addProperty(m_clipPathUnits);
    }

    public inline function clipPathUnits():SVGEnumeration {
        return m_clipPathUnits;
    }

    public function clipBoundingBox(element:SVGElement):lunasvg.Graphics.Rect {
        var clipBoundingBox = paintBoundingBox();
        if (m_clipPathUnits.value() == (Units.ObjectBoundingBox : Int)) {
            var bbox = element.fillBoundingBox();
            clipBoundingBox.x = f32(f32(clipBoundingBox.x * bbox.w) + bbox.x);
            clipBoundingBox.y = f32(f32(clipBoundingBox.y * bbox.h) + bbox.y);
            clipBoundingBox.w = f32(clipBoundingBox.w * bbox.w);
            clipBoundingBox.h = f32(clipBoundingBox.h * bbox.h);
        }

        return localTransform().mapRect(clipBoundingBox);
    }

    public function applyClipMask(state:SVGRenderState):Void {
        if (state.hasCycleReference(this))
            return;
        var maskImage = Canvas.createFromRect(state.currentTransform().mapRect(state.paintBoundingBox()).intersected(state.canvas().extents()));
        var currentTransform = state.currentTransform().mul(localTransform());
        if (m_clipPathUnits.value() == (Units.ObjectBoundingBox : Int)) {
            var bbox = state.fillBoundingBox();
            currentTransform.translate(bbox.x, bbox.y);
            currentTransform.scale(bbox.w, bbox.h);
        }

        var newState = new SVGRenderState(this, state, currentTransform, Clipping, maskImage);
        renderChildren(newState);
        if (clipper() != null) {
            clipper().applyClipMask(newState);
        }

        state.canvas().blendCanvas(maskImage, Dst_In, 1);
    }

    static inline function toSVGGeometryElement(node:Null<SVGNode>):Null<SVGGeometryElement> {
        if (node != null && node.isGeometryElement())
            return cast node;
        return null;
    }

    public function applyClipPath(state:SVGRenderState):Void {
        var currentTransform = state.currentTransform().mul(localTransform());
        if (m_clipPathUnits.value() == (Units.ObjectBoundingBox : Int)) {
            var bbox = state.fillBoundingBox();
            currentTransform.translate(bbox.x, bbox.y);
            currentTransform.scale(bbox.w, bbox.h);
        }

        for (child in children()) {
            var element = SVGElement.toSVGElement(child);
            if (element == null || element.isDisplayNone())
                continue;
            var clipTransform = currentTransform.clone();
            var shapeElement = toSVGGeometryElement(element);
            if (shapeElement == null) {
                if (element.id() != ElementID.Use)
                    continue;
                clipTransform.multiply(element.localTransform());
                shapeElement = toSVGGeometryElement(element.firstChild());
            }

            if (shapeElement == null || !shapeElement.isRenderable())
                continue;
            state.canvas().clipPath(shapeElement.path(), shapeElement.clipRule(), clipTransform.mul(shapeElement.localTransform()));
            return;
        }

        state.canvas().clipRect(lunasvg.Graphics.Rect.empty(), NonZero, Transform.identity());
    }

    public function requiresMasking():Bool {
        if (clipper() != null)
            return true;
        var prevShapeElement:Null<SVGGeometryElement> = null;
        for (child in children()) {
            var element = SVGElement.toSVGElement(child);
            if (element == null || element.isDisplayNone())
                continue;
            var shapeElement = toSVGGeometryElement(element);
            if (shapeElement == null) {
                if (element.isTextPositioningElement())
                    return true;
                if (element.id() != ElementID.Use)
                    continue;
                if (element.clipper() != null)
                    return true;
                shapeElement = toSVGGeometryElement(element.firstChild());
            }

            if (shapeElement == null || !shapeElement.isRenderable())
                continue;
            if (prevShapeElement != null || shapeElement.clipper() != null)
                return true;
            prevShapeElement = shapeElement;
        }

        return false;
    }

}

class SVGMaskElement extends SVGElement {

    var m_x:SVGLength;

    var m_y:SVGLength;

    var m_width:SVGLength;

    var m_height:SVGLength;

    var m_maskUnits:SVGEnumeration;

    var m_maskContentUnits:SVGEnumeration;

    var m_mask_type:MaskType = Luminance;

    public function new(document:Document) {
        super(document, ElementID.Mask);
        m_x = new SVGLength(PropertyID.X, Horizontal, Allow, -10, Percent);
        m_y = new SVGLength(PropertyID.Y, Vertical, Allow, -10, Percent);
        m_width = new SVGLength(PropertyID.Width, Horizontal, Forbid, 120, Percent);
        m_height = new SVGLength(PropertyID.Height, Vertical, Forbid, 120, Percent);
        m_maskUnits = new SVGEnumeration(PropertyID.MaskUnits, (Units.ObjectBoundingBox : Int), SVGEnumeration.UNITS_ENTRIES);
        m_maskContentUnits = new SVGEnumeration(PropertyID.MaskContentUnits, (Units.UserSpaceOnUse : Int), SVGEnumeration.UNITS_ENTRIES);
        addProperty(m_x);
        addProperty(m_y);
        addProperty(m_width);
        addProperty(m_height);
        addProperty(m_maskUnits);
        addProperty(m_maskContentUnits);
    }

    public inline function x():SVGLength {
        return m_x;
    }

    public inline function y():SVGLength {
        return m_y;
    }

    public inline function width():SVGLength {
        return m_width;
    }

    public inline function height():SVGLength {
        return m_height;
    }

    public inline function maskUnits():SVGEnumeration {
        return m_maskUnits;
    }

    public inline function maskContentUnits():SVGEnumeration {
        return m_maskContentUnits;
    }

    public function maskRect(element:SVGElement):lunasvg.Graphics.Rect {
        var lengthContext = new LengthContext(this, (m_maskUnits.value() : Units));
        var maskRect = new lunasvg.Graphics.Rect(
            lengthContext.valueForSVGLength(m_x),
            lengthContext.valueForSVGLength(m_y),
            lengthContext.valueForSVGLength(m_width),
            lengthContext.valueForSVGLength(m_height)
        );

        if (m_maskUnits.value() == (Units.ObjectBoundingBox : Int)) {
            var bbox = element.fillBoundingBox();
            maskRect.x = f32(f32(maskRect.x * bbox.w) + bbox.x);
            maskRect.y = f32(f32(maskRect.y * bbox.h) + bbox.y);
            maskRect.w = f32(maskRect.w * bbox.w);
            maskRect.h = f32(maskRect.h * bbox.h);
        }

        return maskRect;
    }

    public function maskBoundingBox(element:SVGElement):lunasvg.Graphics.Rect {
        var maskBoundingBox = paintBoundingBox();
        if (m_maskContentUnits.value() == (Units.ObjectBoundingBox : Int)) {
            var bbox = element.fillBoundingBox();
            maskBoundingBox.x = f32(f32(maskBoundingBox.x * bbox.w) + bbox.x);
            maskBoundingBox.y = f32(f32(maskBoundingBox.y * bbox.h) + bbox.y);
            maskBoundingBox.w = f32(maskBoundingBox.w * bbox.w);
            maskBoundingBox.h = f32(maskBoundingBox.h * bbox.h);
        }

        return maskBoundingBox.intersected(maskRect(element));
    }

    public function applyMask(state:SVGRenderState):Void {
        if (state.hasCycleReference(this))
            return;
        var maskImage = Canvas.createFromRect(state.currentTransform().mapRect(state.paintBoundingBox()).intersected(state.canvas().extents()));
        maskImage.clipRect(maskRect(state.element()), NonZero, state.currentTransform());

        var currentTransform = state.currentTransform().clone();
        if (m_maskContentUnits.value() == (Units.ObjectBoundingBox : Int)) {
            var bbox = state.fillBoundingBox();
            currentTransform.translate(bbox.x, bbox.y);
            currentTransform.scale(bbox.w, bbox.h);
        }

        var newState = new SVGRenderState(this, state, currentTransform, Painting, maskImage);
        renderChildren(newState);
        if (clipper() != null)
            clipper().applyClipMask(newState);
        if (masker() != null) {
            masker().applyMask(newState);
        }

        if (m_mask_type == Luminance)
            maskImage.convertToLuminanceMask();
        state.canvas().blendCanvas(maskImage, Dst_In, 1);
    }

    override public function layoutElement(state:SVGLayoutState):Void {
        m_mask_type = state.maskType();
        super.layoutElement(state);
    }

}
