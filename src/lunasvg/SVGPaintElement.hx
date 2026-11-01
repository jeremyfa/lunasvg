// Ported from lunasvg 3.5.0: source/svgpaintelement.h, source/svgpaintelement.cpp
// Original code Copyright (c) 2020-2026 Samuel Ugochukwu, licensed under MIT.
// Modified: translated from C++ to Haxe. See LICENSE.
package lunasvg;

import lunasvg.Graphics;
import lunasvg.SVGElement;
import lunasvg.SVGLayoutState;
import lunasvg.SVGProperty;
import lunasvg.SVGRenderState;
import plutovg.Utils.f32;

class SVGPaintElement extends SVGElement {

    public function new(document:Document, id:ElementID) {
        super(document, id);
    }

    override public function isPaintElement():Bool {
        return true;
    }

    public function applyPaint(state:SVGRenderState, opacity:Float):Bool {
        throw "abstract";
    }

}

class SVGStopElement extends SVGElement {

    var m_offset:SVGNumberPercentage;

    var m_stop_color:lunasvg.Graphics.Color = lunasvg.Graphics.Color.Black;

    var m_stop_opacity:Float = 1;

    public function new(document:Document) {
        super(document, ElementID.Stop);
        m_offset = new SVGNumberPercentage(PropertyID.Offset, 0);
        addProperty(m_offset);
    }

    override public function layoutElement(state:SVGLayoutState):Void {
        m_stop_color = state.stopColor();
        m_stop_opacity = state.stopOpacity();
        super.layoutElement(state);
    }

    public inline function offset():SVGNumberPercentage {
        return m_offset;
    }

    public function gradientStop(opacity:Float):GradientStop {
        var stopColor = m_stop_color.colorWithAlpha(f32(m_stop_opacity * opacity));
        return new GradientStop(m_offset.value(), new plutovg.Color(stopColor.redF(), stopColor.greenF(), stopColor.blueF(), stopColor.alphaF()));
    }

}

/**
 * Where each gradient attribute comes from, following `href` links
 * (`SVGGradientAttributes`).
 */
class SVGGradientAttributes {

    var m_gradientTransform:Null<SVGGradientElement> = null;

    var m_spreadMethod:Null<SVGGradientElement> = null;

    var m_gradientUnits:Null<SVGGradientElement> = null;

    var m_gradientContentElement:Null<SVGGradientElement> = null;

    public function new() {}

    public inline function gradientTransform():Transform {
        return m_gradientTransform.gradientTransform().value();
    }

    public inline function spreadMethod():SpreadMethod {
        return m_spreadMethod.spreadMethod().value();
    }

    public inline function gradientUnits():Units {
        return m_gradientUnits.gradientUnits().value();
    }

    public inline function gradientContentElement():SVGGradientElement {
        return m_gradientContentElement;
    }

    public inline function hasGradientTransform():Bool return m_gradientTransform != null;
    public inline function hasSpreadMethod():Bool return m_spreadMethod != null;
    public inline function hasGradientUnits():Bool return m_gradientUnits != null;
    public inline function hasGradientContentElement():Bool return m_gradientContentElement != null;

    public inline function setGradientTransform(value:SVGGradientElement):Void m_gradientTransform = value;
    public inline function setSpreadMethod(value:SVGGradientElement):Void m_spreadMethod = value;
    public inline function setGradientUnits(value:SVGGradientElement):Void m_gradientUnits = value;
    public inline function setGradientContentElement(value:SVGGradientElement):Void m_gradientContentElement = value;

    public function setDefaultValues(element:SVGGradientElement):Void {
        if (m_gradientTransform == null) { m_gradientTransform = element; }
        if (m_spreadMethod == null) { m_spreadMethod = element; }
        if (m_gradientUnits == null) { m_gradientUnits = element; }
        if (m_gradientContentElement == null) { m_gradientContentElement = element; }
    }

}

class SVGGradientElement extends SVGPaintElement {

    var m_uriReference:SVGURIReference;

    var m_gradientTransform:SVGTransform;

    var m_gradientUnits:SVGEnumeration;

    var m_spreadMethod:SVGEnumeration;

    public function new(document:Document, id:ElementID) {
        super(document, id);
        m_uriReference = new SVGURIReference(this);
        m_gradientTransform = new SVGTransform(PropertyID.GradientTransform);
        m_gradientUnits = new SVGEnumeration(PropertyID.GradientUnits, (Units.ObjectBoundingBox : Int), SVGEnumeration.UNITS_ENTRIES);
        m_spreadMethod = new SVGEnumeration(PropertyID.SpreadMethod, (plutovg.SpreadMethod.Pad : Int), SVGEnumeration.SPREAD_METHOD_ENTRIES);
        addProperty(m_gradientTransform);
        addProperty(m_gradientUnits);
        addProperty(m_spreadMethod);
    }

    public inline function gradientTransform():SVGTransform {
        return m_gradientTransform;
    }

    public inline function gradientUnits():SVGEnumeration {
        return m_gradientUnits;
    }

    public inline function spreadMethod():SVGEnumeration {
        return m_spreadMethod;
    }

    public inline function getTargetElement(document:Document):Null<SVGElement> {
        return m_uriReference.getTargetElement(document);
    }

    public function collectGradientAttributes(attributes:SVGGradientAttributes):Void {
        if (!attributes.hasGradientTransform() && hasAttribute(PropertyID.GradientTransform))
            attributes.setGradientTransform(this);
        if (!attributes.hasSpreadMethod() && hasAttribute(PropertyID.SpreadMethod))
            attributes.setSpreadMethod(this);
        if (!attributes.hasGradientUnits() && hasAttribute(PropertyID.GradientUnits))
            attributes.setGradientUnits(this);
        if (!attributes.hasGradientContentElement()) {
            for (child in children()) {
                var element = SVGElement.toSVGElement(child);
                if (element != null && element.id() == ElementID.Stop) {
                    attributes.setGradientContentElement(this);
                    break;
                }
            }
        }
    }

    static function buildGradientStops(element:SVGGradientElement, opacity:Float):GradientStops {
        var gradientStops:GradientStops = [];
        for (child in element.children()) {
            var childElement = SVGElement.toSVGElement(child);
            if (childElement != null && childElement.id() == ElementID.Stop) {
                var stopElement:SVGStopElement = cast childElement;
                gradientStops.push(stopElement.gradientStop(opacity));
            }
        }

        return gradientStops;
    }

    /**
     * Shared tail of the linear and radial `applyPaint()`: returns the
     * gradient transform including the object bounding box mapping.
     */
    static function gradientTransformFor(attributes:SVGGradientAttributes, state:SVGRenderState):Transform {
        var gradientUnits = attributes.gradientUnits();
        var gradientTransform = attributes.gradientTransform().clone();
        if (gradientUnits == ObjectBoundingBox) {
            var bbox = state.fillBoundingBox();
            gradientTransform.postMultiply(new Transform(bbox.w, 0, 0, bbox.h, bbox.x, bbox.y));
        }
        return gradientTransform;
    }

}

class SVGLinearGradientAttributes extends SVGGradientAttributes {

    var m_x1:Null<SVGLinearGradientElement> = null;

    var m_y1:Null<SVGLinearGradientElement> = null;

    var m_x2:Null<SVGLinearGradientElement> = null;

    var m_y2:Null<SVGLinearGradientElement> = null;

    public function new() {
        super();
    }

    public inline function x1():SVGLength return m_x1.x1();
    public inline function y1():SVGLength return m_y1.y1();
    public inline function x2():SVGLength return m_x2.x2();
    public inline function y2():SVGLength return m_y2.y2();

    public inline function hasX1():Bool return m_x1 != null;
    public inline function hasY1():Bool return m_y1 != null;
    public inline function hasX2():Bool return m_x2 != null;
    public inline function hasY2():Bool return m_y2 != null;

    public inline function setX1(value:SVGLinearGradientElement):Void m_x1 = value;
    public inline function setY1(value:SVGLinearGradientElement):Void m_y1 = value;
    public inline function setX2(value:SVGLinearGradientElement):Void m_x2 = value;
    public inline function setY2(value:SVGLinearGradientElement):Void m_y2 = value;

    public function setLinearDefaultValues(element:SVGLinearGradientElement):Void {
        setDefaultValues(element);
        if (m_x1 == null) { m_x1 = element; }
        if (m_y1 == null) { m_y1 = element; }
        if (m_x2 == null) { m_x2 = element; }
        if (m_y2 == null) { m_y2 = element; }
    }

}

class SVGLinearGradientElement extends SVGGradientElement {

    var m_x1:SVGLength;

    var m_y1:SVGLength;

    var m_x2:SVGLength;

    var m_y2:SVGLength;

    public function new(document:Document) {
        super(document, ElementID.LinearGradient);
        m_x1 = new SVGLength(PropertyID.X1, Horizontal, Allow, 0, Percent);
        m_y1 = new SVGLength(PropertyID.Y1, Vertical, Allow, 0, Percent);
        m_x2 = new SVGLength(PropertyID.X2, Horizontal, Allow, 100, Percent);
        m_y2 = new SVGLength(PropertyID.Y2, Vertical, Allow, 0, Percent);
        addProperty(m_x1);
        addProperty(m_y1);
        addProperty(m_x2);
        addProperty(m_y2);
    }

    public inline function x1():SVGLength return m_x1;
    public inline function y1():SVGLength return m_y1;
    public inline function x2():SVGLength return m_x2;
    public inline function y2():SVGLength return m_y2;

    function collectLinearGradientAttributes():SVGLinearGradientAttributes {
        var attributes = new SVGLinearGradientAttributes();
        var processedGradients:Array<SVGGradientElement> = [];
        var current:SVGGradientElement = this;
        while (true) {
            current.collectGradientAttributes(attributes);
            if (current.id() == ElementID.LinearGradient) {
                var element:SVGLinearGradientElement = cast current;
                if (!attributes.hasX1() && element.hasAttribute(PropertyID.X1))
                    attributes.setX1(element);
                if (!attributes.hasY1() && element.hasAttribute(PropertyID.Y1))
                    attributes.setY1(element);
                if (!attributes.hasX2() && element.hasAttribute(PropertyID.X2))
                    attributes.setX2(element);
                if (!attributes.hasY2() && element.hasAttribute(PropertyID.Y2)) {
                    attributes.setY2(element);
                }
            }

            var targetElement = current.getTargetElement(document());
            if (targetElement == null || !(targetElement.id() == ElementID.LinearGradient || targetElement.id() == ElementID.RadialGradient))
                break;
            processedGradients.push(current);
            current = cast targetElement;
            if (processedGradients.indexOf(current) >= 0) {
                break;
            }
        }

        attributes.setLinearDefaultValues(this);
        return attributes;
    }

    override public function applyPaint(state:SVGRenderState, opacity:Float):Bool {
        var attributes = collectLinearGradientAttributes();
        var gradientContentElement = attributes.gradientContentElement();
        var gradientStops = @:privateAccess SVGGradientElement.buildGradientStops(gradientContentElement, opacity);
        if (gradientStops.length == 0)
            return false;
        var lengthContext = new LengthContext(this, attributes.gradientUnits());
        var x1 = lengthContext.valueForSVGLength(attributes.x1());
        var y1 = lengthContext.valueForSVGLength(attributes.y1());
        var x2 = lengthContext.valueForSVGLength(attributes.x2());
        var y2 = lengthContext.valueForSVGLength(attributes.y2());
        if (gradientStops.length == 1 || (x1 == x2 && y1 == y2)) {
            var lastStop = gradientStops[gradientStops.length - 1];
            state.canvas().setColorRgba(lastStop.color.r, lastStop.color.g, lastStop.color.b, lastStop.color.a);
            return true;
        }

        var spreadMethod = attributes.spreadMethod();
        var gradientTransform = @:privateAccess SVGGradientElement.gradientTransformFor(attributes, state);
        state.canvas().setLinearGradient(x1, y1, x2, y2, spreadMethod, gradientStops, gradientTransform);
        return true;
    }

}

class SVGRadialGradientAttributes extends SVGGradientAttributes {

    var m_cx:Null<SVGRadialGradientElement> = null;

    var m_cy:Null<SVGRadialGradientElement> = null;

    var m_r:Null<SVGRadialGradientElement> = null;

    var m_fx:Null<SVGRadialGradientElement> = null;

    var m_fy:Null<SVGRadialGradientElement> = null;

    public function new() {
        super();
    }

    public inline function cx():SVGLength return m_cx.cx();
    public inline function cy():SVGLength return m_cy.cy();
    public inline function r():SVGLength return m_r.r();
    public inline function fx():SVGLength return m_fx != null ? m_fx.fx() : m_cx.cx();
    public inline function fy():SVGLength return m_fy != null ? m_fy.fy() : m_cy.cy();

    public inline function hasCx():Bool return m_cx != null;
    public inline function hasCy():Bool return m_cy != null;
    public inline function hasR():Bool return m_r != null;
    public inline function hasFx():Bool return m_fx != null;
    public inline function hasFy():Bool return m_fy != null;

    public inline function setCx(value:SVGRadialGradientElement):Void m_cx = value;
    public inline function setCy(value:SVGRadialGradientElement):Void m_cy = value;
    public inline function setR(value:SVGRadialGradientElement):Void m_r = value;
    public inline function setFx(value:SVGRadialGradientElement):Void m_fx = value;
    public inline function setFy(value:SVGRadialGradientElement):Void m_fy = value;

    public function setRadialDefaultValues(element:SVGRadialGradientElement):Void {
        setDefaultValues(element);
        if (m_cx == null) { m_cx = element; }
        if (m_cy == null) { m_cy = element; }
        if (m_r == null) { m_r = element; }
    }

}

class SVGRadialGradientElement extends SVGGradientElement {

    var m_cx:SVGLength;

    var m_cy:SVGLength;

    var m_r:SVGLength;

    var m_fx:SVGLength;

    var m_fy:SVGLength;

    public function new(document:Document) {
        super(document, ElementID.RadialGradient);
        m_cx = new SVGLength(PropertyID.Cx, Horizontal, Allow, 50, Percent);
        m_cy = new SVGLength(PropertyID.Cy, Vertical, Allow, 50, Percent);
        m_r = new SVGLength(PropertyID.R, Diagonal, Forbid, 50, Percent);
        m_fx = new SVGLength(PropertyID.Fx, Horizontal, Allow, 0, None);
        m_fy = new SVGLength(PropertyID.Fy, Vertical, Allow, 0, None);
        addProperty(m_cx);
        addProperty(m_cy);
        addProperty(m_r);
        addProperty(m_fx);
        addProperty(m_fy);
    }

    public inline function cx():SVGLength return m_cx;
    public inline function cy():SVGLength return m_cy;
    public inline function r():SVGLength return m_r;
    public inline function fx():SVGLength return m_fx;
    public inline function fy():SVGLength return m_fy;

    override public function applyPaint(state:SVGRenderState, opacity:Float):Bool {
        var attributes = collectRadialGradientAttributes();
        var gradientContentElement = attributes.gradientContentElement();
        var gradientStops = @:privateAccess SVGGradientElement.buildGradientStops(gradientContentElement, opacity);
        if (gradientStops.length == 0)
            return false;
        var lengthContext = new LengthContext(this, attributes.gradientUnits());
        var r = lengthContext.valueForSVGLength(attributes.r());
        if (r == 0 || gradientStops.length == 1) {
            var lastStop = gradientStops[gradientStops.length - 1];
            state.canvas().setColorRgba(lastStop.color.r, lastStop.color.g, lastStop.color.b, lastStop.color.a);
            return true;
        }

        var fx = lengthContext.valueForSVGLength(attributes.fx());
        var fy = lengthContext.valueForSVGLength(attributes.fy());
        var cx = lengthContext.valueForSVGLength(attributes.cx());
        var cy = lengthContext.valueForSVGLength(attributes.cy());

        var spreadMethod = attributes.spreadMethod();
        var gradientTransform = @:privateAccess SVGGradientElement.gradientTransformFor(attributes, state);
        state.canvas().setRadialGradient(cx, cy, r, fx, fy, spreadMethod, gradientStops, gradientTransform);
        return true;
    }

    function collectRadialGradientAttributes():SVGRadialGradientAttributes {
        var attributes = new SVGRadialGradientAttributes();
        var processedGradients:Array<SVGGradientElement> = [];
        var current:SVGGradientElement = this;
        while (true) {
            current.collectGradientAttributes(attributes);
            if (current.id() == ElementID.RadialGradient) {
                var element:SVGRadialGradientElement = cast current;
                if (!attributes.hasCx() && element.hasAttribute(PropertyID.Cx))
                    attributes.setCx(element);
                if (!attributes.hasCy() && element.hasAttribute(PropertyID.Cy))
                    attributes.setCy(element);
                if (!attributes.hasR() && element.hasAttribute(PropertyID.R))
                    attributes.setR(element);
                if (!attributes.hasFx() && element.hasAttribute(PropertyID.Fx))
                    attributes.setFx(element);
                if (!attributes.hasFy() && element.hasAttribute(PropertyID.Fy)) {
                    attributes.setFy(element);
                }
            }

            var targetElement = current.getTargetElement(document());
            if (targetElement == null || !(targetElement.id() == ElementID.LinearGradient || targetElement.id() == ElementID.RadialGradient))
                break;
            processedGradients.push(current);
            current = cast targetElement;
            if (processedGradients.indexOf(current) >= 0) {
                break;
            }
        }

        attributes.setRadialDefaultValues(this);
        return attributes;
    }

}

class SVGPatternAttributes {

    var m_x:Null<SVGPatternElement> = null;
    var m_y:Null<SVGPatternElement> = null;
    var m_width:Null<SVGPatternElement> = null;
    var m_height:Null<SVGPatternElement> = null;
    var m_patternTransform:Null<SVGPatternElement> = null;
    var m_patternUnits:Null<SVGPatternElement> = null;
    var m_patternContentUnits:Null<SVGPatternElement> = null;
    var m_viewBox:Null<SVGPatternElement> = null;
    var m_preserveAspectRatio:Null<SVGPatternElement> = null;
    var m_patternContentElement:Null<SVGPatternElement> = null;

    public function new() {}

    public inline function x():SVGLength return m_x.x();
    public inline function y():SVGLength return m_y.y();
    public inline function width():SVGLength return m_width.width();
    public inline function height():SVGLength return m_height.height();
    public inline function patternTransform():Transform return m_patternTransform.patternTransform().value();
    public inline function patternUnits():Units return m_patternUnits.patternUnits().value();
    public inline function patternContentUnits():Units return m_patternContentUnits.patternContentUnits().value();
    public inline function viewBox():lunasvg.Graphics.Rect return m_viewBox.viewBox().value();
    public inline function preserveAspectRatio():SVGPreserveAspectRatio return m_preserveAspectRatio.preserveAspectRatio();
    public inline function patternContentElement():Null<SVGPatternElement> return m_patternContentElement;

    public inline function hasX():Bool return m_x != null;
    public inline function hasY():Bool return m_y != null;
    public inline function hasWidth():Bool return m_width != null;
    public inline function hasHeight():Bool return m_height != null;
    public inline function hasPatternTransform():Bool return m_patternTransform != null;
    public inline function hasPatternUnits():Bool return m_patternUnits != null;
    public inline function hasPatternContentUnits():Bool return m_patternContentUnits != null;
    public inline function hasViewBox():Bool return m_viewBox != null;
    public inline function hasPreserveAspectRatio():Bool return m_preserveAspectRatio != null;
    public inline function hasPatternContentElement():Bool return m_patternContentElement != null;

    public inline function setX(value:SVGPatternElement):Void m_x = value;
    public inline function setY(value:SVGPatternElement):Void m_y = value;
    public inline function setWidth(value:SVGPatternElement):Void m_width = value;
    public inline function setHeight(value:SVGPatternElement):Void m_height = value;
    public inline function setPatternTransform(value:SVGPatternElement):Void m_patternTransform = value;
    public inline function setPatternUnits(value:SVGPatternElement):Void m_patternUnits = value;
    public inline function setPatternContentUnits(value:SVGPatternElement):Void m_patternContentUnits = value;
    public inline function setViewBox(value:SVGPatternElement):Void m_viewBox = value;
    public inline function setPreserveAspectRatio(value:SVGPatternElement):Void m_preserveAspectRatio = value;
    public inline function setPatternContentElement(value:SVGPatternElement):Void m_patternContentElement = value;

    public function setDefaultValues(element:SVGPatternElement):Void {
        if (m_x == null) { m_x = element; }
        if (m_y == null) { m_y = element; }
        if (m_width == null) { m_width = element; }
        if (m_height == null) { m_height = element; }
        if (m_patternTransform == null) { m_patternTransform = element; }
        if (m_patternUnits == null) { m_patternUnits = element; }
        if (m_patternContentUnits == null) { m_patternContentUnits = element; }
        if (m_viewBox == null) { m_viewBox = element; }
        if (m_preserveAspectRatio == null) { m_preserveAspectRatio = element; }
        if (m_patternContentElement == null) { m_patternContentElement = element; }
    }

}

class SVGPatternElement extends SVGPaintElement {

    var m_uriReference:SVGURIReference;

    var m_fitToViewBox:SVGFitToViewBox;

    var m_x:SVGLength;

    var m_y:SVGLength;

    var m_width:SVGLength;

    var m_height:SVGLength;

    var m_patternTransform:SVGTransform;

    var m_patternUnits:SVGEnumeration;

    var m_patternContentUnits:SVGEnumeration;

    public function new(document:Document) {
        super(document, ElementID.Pattern);
        m_uriReference = new SVGURIReference(this);
        m_fitToViewBox = new SVGFitToViewBox(this);
        m_x = new SVGLength(PropertyID.X, Horizontal, Allow);
        m_y = new SVGLength(PropertyID.Y, Vertical, Allow);
        m_width = new SVGLength(PropertyID.Width, Horizontal, Forbid);
        m_height = new SVGLength(PropertyID.Height, Vertical, Forbid);
        m_patternTransform = new SVGTransform(PropertyID.PatternTransform);
        m_patternUnits = new SVGEnumeration(PropertyID.PatternUnits, (Units.ObjectBoundingBox : Int), SVGEnumeration.UNITS_ENTRIES);
        m_patternContentUnits = new SVGEnumeration(PropertyID.PatternContentUnits, (Units.UserSpaceOnUse : Int), SVGEnumeration.UNITS_ENTRIES);
        addProperty(m_x);
        addProperty(m_y);
        addProperty(m_width);
        addProperty(m_height);
        addProperty(m_patternTransform);
        addProperty(m_patternUnits);
        addProperty(m_patternContentUnits);
    }

    public inline function x():SVGLength return m_x;
    public inline function y():SVGLength return m_y;
    public inline function width():SVGLength return m_width;
    public inline function height():SVGLength return m_height;
    public inline function patternTransform():SVGTransform return m_patternTransform;
    public inline function patternUnits():SVGEnumeration return m_patternUnits;
    public inline function patternContentUnits():SVGEnumeration return m_patternContentUnits;
    public inline function viewBox():SVGRect return m_fitToViewBox.viewBox();
    public inline function preserveAspectRatio():SVGPreserveAspectRatio return m_fitToViewBox.preserveAspectRatio();

    public inline function getTargetElement(document:Document):Null<SVGElement> {
        return m_uriReference.getTargetElement(document);
    }

    override public function applyPaint(state:SVGRenderState, opacity:Float):Bool {
        if (state.hasCycleReference(this))
            return false;
        var attributes = collectPatternAttributes();
        var patternContentElement = attributes.patternContentElement();
        if (patternContentElement == null)
            return false;
        var lengthContext = new LengthContext(this, attributes.patternUnits());
        var patternRect = new lunasvg.Graphics.Rect(
            lengthContext.valueForSVGLength(attributes.x()),
            lengthContext.valueForSVGLength(attributes.y()),
            lengthContext.valueForSVGLength(attributes.width()),
            lengthContext.valueForSVGLength(attributes.height())
        );

        if (attributes.patternUnits() == ObjectBoundingBox) {
            var bbox = state.fillBoundingBox();
            patternRect.x = f32(f32(patternRect.x * bbox.w) + bbox.x);
            patternRect.y = f32(f32(patternRect.y * bbox.h) + bbox.y);
            patternRect.w = f32(patternRect.w * bbox.w);
            patternRect.h = f32(patternRect.h * bbox.h);
        }

        var currentTransform = attributes.patternTransform().mul(state.currentTransform());
        var xScale = currentTransform.xScale();
        var yScale = currentTransform.yScale();

        var patternImage = Canvas.create(0, 0, f32(patternRect.w * xScale), f32(patternRect.h * yScale));
        var patternImageTransform = Transform.scaled(xScale, yScale);

        var viewBoxRect = attributes.viewBox();
        if (viewBoxRect.isValid()) {
            var preserveAspectRatio = attributes.preserveAspectRatio();
            patternImageTransform.multiply(preserveAspectRatio.getTransform(viewBoxRect, patternRect.size()));
        } else if (attributes.patternContentUnits() == ObjectBoundingBox) {
            var bbox = state.fillBoundingBox();
            patternImageTransform.scale(bbox.w, bbox.h);
        }

        var newState = new SVGRenderState(this, state, patternImageTransform, Painting, patternImage);
        patternContentElement.renderChildren(newState);

        var patternTransform = attributes.patternTransform().clone();
        patternTransform.translate(patternRect.x, patternRect.y);
        patternTransform.scale(f32(patternRect.w / patternImage.width()), f32(patternRect.h / patternImage.height()));
        state.canvas().setTexture(patternImage, Tiled, opacity, patternTransform);
        return true;
    }

    function collectPatternAttributes():SVGPatternAttributes {
        var attributes = new SVGPatternAttributes();
        var processedPatterns:Array<SVGPatternElement> = [];
        var current:SVGPatternElement = this;
        while (true) {
            if (!attributes.hasX() && current.hasAttribute(PropertyID.X))
                attributes.setX(current);
            if (!attributes.hasY() && current.hasAttribute(PropertyID.Y))
                attributes.setY(current);
            if (!attributes.hasWidth() && current.hasAttribute(PropertyID.Width))
                attributes.setWidth(current);
            if (!attributes.hasHeight() && current.hasAttribute(PropertyID.Height))
                attributes.setHeight(current);
            if (!attributes.hasPatternTransform() && current.hasAttribute(PropertyID.PatternTransform))
                attributes.setPatternTransform(current);
            if (!attributes.hasPatternUnits() && current.hasAttribute(PropertyID.PatternUnits))
                attributes.setPatternUnits(current);
            if (!attributes.hasPatternContentUnits() && current.hasAttribute(PropertyID.PatternContentUnits))
                attributes.setPatternContentUnits(current);
            if (!attributes.hasViewBox() && current.hasAttribute(PropertyID.ViewBox))
                attributes.setViewBox(current);
            if (!attributes.hasPreserveAspectRatio() && current.hasAttribute(PropertyID.PreserveAspectRatio))
                attributes.setPreserveAspectRatio(current);
            if (!attributes.hasPatternContentElement()) {
                for (child in current.children()) {
                    if (child.isElement()) {
                        attributes.setPatternContentElement(current);
                        break;
                    }
                }
            }

            var targetElement = current.getTargetElement(document());
            if (targetElement == null || targetElement.id() != ElementID.Pattern)
                break;
            processedPatterns.push(current);
            current = cast targetElement;
            if (processedPatterns.indexOf(current) >= 0) {
                break;
            }
        }

        attributes.setDefaultValues(this);
        return attributes;
    }

}
