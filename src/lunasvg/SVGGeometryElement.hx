// Ported from lunasvg 3.5.0: source/svggeometryelement.h, source/svggeometryelement.cpp
// Original code Copyright (c) 2020-2026 Samuel Ugochukwu, licensed under MIT.
// Modified: translated from C++ to Haxe. See LICENSE.
package lunasvg;

import lunasvg.Graphics;
import lunasvg.SVGElement;
import lunasvg.SVGLayoutState;
import lunasvg.SVGProperty;
import lunasvg.SVGRenderState;
import plutovg.Utils.f32;

class SVGMarkerPosition {

    var m_element:SVGMarkerElement;

    var m_origin:Point;

    var m_angle:Float;

    public function new(element:SVGMarkerElement, origin:Point, angle:Float) {
        m_element = element;
        m_origin = origin.clone();
        m_angle = f32(angle);
    }

    public inline function element():SVGMarkerElement {
        return m_element;
    }

    public inline function origin():Point {
        return m_origin;
    }

    public inline function angle():Float {
        return m_angle;
    }

    public function markerBoundingBox(strokeWidth:Float):lunasvg.Graphics.Rect {
        return m_element.markerBoundingBox(m_origin, m_angle, strokeWidth);
    }

    public function renderMarker(state:SVGRenderState, strokeWidth:Float):Void {
        m_element.renderMarker(state, m_origin, m_angle, strokeWidth);
    }

}

typedef SVGMarkerPositionList = Array<SVGMarkerPosition>;

class SVGGeometryElement extends SVGGraphicsElement {

    var m_path:lunasvg.Graphics.Path = new lunasvg.Graphics.Path();

    var m_fillBoundingBox:lunasvg.Graphics.Rect = new lunasvg.Graphics.Rect();

    var m_strokeData:StrokeData = new StrokeData();

    var m_fill:SVGPaintServer = new SVGPaintServer();

    var m_stroke:SVGPaintServer = new SVGPaintServer();

    var m_markerPositions:SVGMarkerPositionList = [];

    var m_fill_rule:FillRule = NonZero;

    var m_clip_rule:FillRule = NonZero;

    public function new(document:Document, id:ElementID) {
        super(document, id);
    }

    override public function isGeometryElement():Bool {
        return true;
    }

    override public function fillBoundingBox():lunasvg.Graphics.Rect {
        return m_fillBoundingBox.clone();
    }

    override public function strokeBoundingBox():lunasvg.Graphics.Rect {
        var strokeBoundingBox = fillBoundingBox();
        if (m_stroke.isRenderable()) {
            var capLimit = f32(m_strokeData.lineWidth() / 2);
            if (m_strokeData.lineCap() == Square)
                capLimit = f32(capLimit * plutovg.Plutovg.SQRT2);
            var joinLimit = f32(m_strokeData.lineWidth() / 2);
            if (m_strokeData.lineJoin() == Miter) {
                joinLimit = f32(joinLimit * m_strokeData.miterLimit());
            }

            var d = Math.max(capLimit, joinLimit);
            strokeBoundingBox.inflate(d, d);
        }

        for (markerPosition in m_markerPositions)
            strokeBoundingBox.unite(markerPosition.markerBoundingBox(m_strokeData.lineWidth()));
        return strokeBoundingBox;
    }

    override public function layoutElement(state:SVGLayoutState):Void {
        m_fill_rule = state.fillRule();
        m_clip_rule = state.clipRule();
        m_fill = getPaintServer(state.fill(), state.fillOpacity());
        m_stroke = getPaintServer(state.stroke(), state.strokeOpacity());
        m_strokeData = getStrokeData(state);
        super.layoutElement(state);

        m_path.reset();
        m_markerPositions = [];
        m_fillBoundingBox = updateShape(m_path);
        updateMarkerPositions(m_markerPositions, state);
    }

    public inline function isRenderable():Bool {
        return !m_path.isNull() && !isDisplayNone() && !isVisibilityHidden();
    }

    public inline function fillRule():FillRule {
        return m_fill_rule;
    }

    public inline function clipRule():FillRule {
        return m_clip_rule;
    }

    public function updateShape(path:lunasvg.Graphics.Path):lunasvg.Graphics.Rect {
        throw "abstract";
    }

    static inline function angleOf(dx:Float, dy:Float):Float {
        return f32(f32(180 * f32(Math.atan2(dy, dx))) / plutovg.Plutovg.PI);
    }

    public function updateMarkerPositions(positions:SVGMarkerPositionList, state:SVGLayoutState):Void {
        if (m_path.isEmpty())
            return;
        var markerStart = getMarker(state.markerStart());
        var markerMid = getMarker(state.markerMid());
        var markerEnd = getMarker(state.markerEnd());
        if (markerStart == null && markerMid == null && markerEnd == null) {
            return;
        }

        var origin = new Point();
        var startPoint = new Point();
        var inslopePoints = [new Point(), new Point()];
        var outslopePoints = [new Point(), new Point()];

        var index = 0;
        var points = [new Point(), new Point(), new Point()];
        var it = new PathIterator(m_path);
        while (!it.isDone()) {
            switch (it.currentSegment(points)) {
                case MoveTo:
                    startPoint = points[0].clone();
                    inslopePoints[0] = origin.clone();
                    inslopePoints[1] = points[0].clone();
                    origin = points[0].clone();
                case LineTo:
                    inslopePoints[0] = origin.clone();
                    inslopePoints[1] = points[0].clone();
                    origin = points[0].clone();
                case CubicTo:
                    inslopePoints[0] = points[1].clone();
                    inslopePoints[1] = points[2].clone();
                    origin = points[2].clone();
                case Close:
                    inslopePoints[0] = origin.clone();
                    inslopePoints[1] = points[0].clone();
                    origin = startPoint.clone();
                    startPoint = new Point();
            }

            it.next();

            if (!it.isDone() && (markerStart != null || markerMid != null)) {
                it.currentSegment(points);
                outslopePoints[0] = origin.clone();
                outslopePoints[1] = points[0].clone();
                if (index == 0 && markerStart != null) {
                    var slope = outslopePoints[1].sub(outslopePoints[0]);
                    var angle = angleOf(slope.x, slope.y);
                    var orient = markerStart.orient();
                    if (orient.orientType() == AutoStartReverse)
                        angle = f32(angle - 180);
                    positions.push(new SVGMarkerPosition(markerStart, origin, angle));
                }

                if (index > 0 && markerMid != null) {
                    var inslope = inslopePoints[1].sub(inslopePoints[0]);
                    var outslope = outslopePoints[1].sub(outslopePoints[0]);
                    var inangle = angleOf(inslope.x, inslope.y);
                    var outangle = angleOf(outslope.x, outslope.y);
                    if (Math.abs(f32(inangle - outangle)) > 180)
                        inangle = f32(inangle + 360);
                    var angle = f32(f32(inangle + outangle) * 0.5);
                    positions.push(new SVGMarkerPosition(markerMid, origin, angle));
                }
            }

            if (markerEnd != null && it.isDone()) {
                var slope = inslopePoints[1].sub(inslopePoints[0]);
                var angle = angleOf(slope.x, slope.y);
                positions.push(new SVGMarkerPosition(markerEnd, origin, angle));
            }

            index += 1;
        }
    }

    override public function render(state:SVGRenderState):Void {
        if (!isRenderable())
            return;
        var blendInfo = SVGBlendInfo.of(this);
        var newState = SVGRenderState.child(this, state, localTransform());
        newState.beginGroup(blendInfo);
        if (newState.mode() == Clipping) {
            newState.canvas().setColor(lunasvg.Graphics.Color.White);
            newState.canvas().fillPath(m_path, m_clip_rule, newState.currentTransform());
        } else {
            if (m_fill.applyPaint(newState))
                newState.canvas().fillPath(m_path, m_fill_rule, newState.currentTransform());
            if (m_stroke.applyPaint(newState)) {
                newState.canvas().strokePath(m_path, m_strokeData, newState.currentTransform());
            }

            for (markerPosition in m_markerPositions) {
                markerPosition.renderMarker(newState, m_strokeData.lineWidth());
            }
        }

        newState.endGroup(blendInfo);
    }

    public inline function path():lunasvg.Graphics.Path {
        return m_path;
    }

}

class SVGLineElement extends SVGGeometryElement {

    var m_x1:SVGLength;

    var m_y1:SVGLength;

    var m_x2:SVGLength;

    var m_y2:SVGLength;

    public function new(document:Document) {
        super(document, ElementID.Line);
        m_x1 = new SVGLength(PropertyID.X1, Horizontal, Allow);
        m_y1 = new SVGLength(PropertyID.Y1, Vertical, Allow);
        m_x2 = new SVGLength(PropertyID.X2, Horizontal, Allow);
        m_y2 = new SVGLength(PropertyID.Y2, Vertical, Allow);
        addProperty(m_x1);
        addProperty(m_y1);
        addProperty(m_x2);
        addProperty(m_y2);
    }

    override public function updateShape(path:lunasvg.Graphics.Path):lunasvg.Graphics.Rect {
        var lengthContext = new LengthContext(this);
        var x1 = lengthContext.valueForSVGLength(m_x1);
        var y1 = lengthContext.valueForSVGLength(m_y1);
        var x2 = lengthContext.valueForSVGLength(m_x2);
        var y2 = lengthContext.valueForSVGLength(m_y2);

        path.moveTo(x1, y1);
        path.lineTo(x2, y2);
        return new lunasvg.Graphics.Rect(x1, y1, x2 - x1, y2 - y1);
    }

}

class SVGRectElement extends SVGGeometryElement {

    var m_x:SVGLength;

    var m_y:SVGLength;

    var m_width:SVGLength;

    var m_height:SVGLength;

    var m_rx:SVGLength;

    var m_ry:SVGLength;

    public function new(document:Document) {
        super(document, ElementID.Rect);
        m_x = new SVGLength(PropertyID.X, Horizontal, Allow);
        m_y = new SVGLength(PropertyID.Y, Vertical, Allow);
        m_width = new SVGLength(PropertyID.Width, Horizontal, Forbid);
        m_height = new SVGLength(PropertyID.Height, Vertical, Forbid);
        m_rx = new SVGLength(PropertyID.Rx, Horizontal, Forbid);
        m_ry = new SVGLength(PropertyID.Ry, Vertical, Forbid);
        addProperty(m_x);
        addProperty(m_y);
        addProperty(m_width);
        addProperty(m_height);
        addProperty(m_rx);
        addProperty(m_ry);
    }

    override public function updateShape(path:lunasvg.Graphics.Path):lunasvg.Graphics.Rect {
        var lengthContext = new LengthContext(this);
        var width = lengthContext.valueForSVGLength(m_width);
        var height = lengthContext.valueForSVGLength(m_height);
        if (width <= 0 || height <= 0) {
            return lunasvg.Graphics.Rect.empty();
        }

        var x = lengthContext.valueForSVGLength(m_x);
        var y = lengthContext.valueForSVGLength(m_y);

        var rx = lengthContext.valueForSVGLength(m_rx);
        var ry = lengthContext.valueForSVGLength(m_ry);

        if (rx <= 0) rx = ry;
        if (ry <= 0) ry = rx;

        rx = Math.min(rx, f32(width / 2));
        ry = Math.min(ry, f32(height / 2));

        path.addRoundRect(x, y, width, height, rx, ry);
        return new lunasvg.Graphics.Rect(x, y, width, height);
    }

}

class SVGEllipseElement extends SVGGeometryElement {

    var m_cx:SVGLength;

    var m_cy:SVGLength;

    var m_rx:SVGLength;

    var m_ry:SVGLength;

    public function new(document:Document) {
        super(document, ElementID.Ellipse);
        m_cx = new SVGLength(PropertyID.Cx, Horizontal, Allow);
        m_cy = new SVGLength(PropertyID.Cy, Vertical, Allow);
        m_rx = new SVGLength(PropertyID.Rx, Diagonal, Forbid);
        m_ry = new SVGLength(PropertyID.Ry, Diagonal, Forbid);
        addProperty(m_cx);
        addProperty(m_cy);
        addProperty(m_rx);
        addProperty(m_ry);
    }

    override public function updateShape(path:lunasvg.Graphics.Path):lunasvg.Graphics.Rect {
        var lengthContext = new LengthContext(this);
        var rx = lengthContext.valueForSVGLength(m_rx);
        var ry = lengthContext.valueForSVGLength(m_ry);
        if (rx <= 0 || ry <= 0) {
            return lunasvg.Graphics.Rect.empty();
        }

        var cx = lengthContext.valueForSVGLength(m_cx);
        var cy = lengthContext.valueForSVGLength(m_cy);
        path.addEllipse(cx, cy, rx, ry);
        return new lunasvg.Graphics.Rect(cx - rx, cy - ry, rx + rx, ry + ry);
    }

}

class SVGCircleElement extends SVGGeometryElement {

    var m_cx:SVGLength;

    var m_cy:SVGLength;

    var m_r:SVGLength;

    public function new(document:Document) {
        super(document, ElementID.Circle);
        m_cx = new SVGLength(PropertyID.Cx, Horizontal, Allow);
        m_cy = new SVGLength(PropertyID.Cy, Vertical, Allow);
        m_r = new SVGLength(PropertyID.R, Diagonal, Forbid);
        addProperty(m_cx);
        addProperty(m_cy);
        addProperty(m_r);
    }

    override public function updateShape(path:lunasvg.Graphics.Path):lunasvg.Graphics.Rect {
        var lengthContext = new LengthContext(this);
        var r = lengthContext.valueForSVGLength(m_r);
        if (r <= 0) {
            return lunasvg.Graphics.Rect.empty();
        }

        var cx = lengthContext.valueForSVGLength(m_cx);
        var cy = lengthContext.valueForSVGLength(m_cy);
        path.addEllipse(cx, cy, r, r);
        return new lunasvg.Graphics.Rect(cx - r, cy - r, r + r, r + r);
    }

}

class SVGPolyElement extends SVGGeometryElement {

    var m_points:SVGPointList;

    public function new(document:Document, id:ElementID) {
        super(document, id);
        m_points = new SVGPointList(PropertyID.Points);
        addProperty(m_points);
    }

    override public function updateShape(path:lunasvg.Graphics.Path):lunasvg.Graphics.Rect {
        var points = m_points.values();
        if (points.length == 0) {
            return lunasvg.Graphics.Rect.empty();
        }

        path.moveTo(points[0].x, points[0].y);
        for (i in 1...points.length) {
            path.lineTo(points[i].x, points[i].y);
        }

        if (id() == ElementID.Polygon)
            path.close();
        return path.boundingRect();
    }

}

class SVGPathElement extends SVGGeometryElement {

    var m_d:SVGPath;

    public function new(document:Document) {
        super(document, ElementID.Path);
        m_d = new SVGPath(PropertyID.D);
        addProperty(m_d);
    }

    override public function updateShape(path:lunasvg.Graphics.Path):lunasvg.Graphics.Rect {
        path.assign(m_d.value());
        return path.boundingRect();
    }

}
