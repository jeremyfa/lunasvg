// Ported from lunasvg 3.5.0: source/svgproperty.h, source/svgproperty.cpp
// Original code Copyright (c) 2020-2026 Samuel Ugochukwu, licensed under MIT.
// Modified: translated from C++ to Haxe. See LICENSE.
package lunasvg;

import lunasvg.Graphics;
import lunasvg.SVGElement;
import lunasvg.SVGParserUtils;
import lunasvg.SVGParserUtils.SVGParserUtils.*;
import plutovg.Utils.f32;

/**
 * Not an `enum abstract`: its values would shadow type names (`Color`,
 * `Transform`, `Rect`...) in every module importing it. Always qualify them.
 */
abstract PropertyID(Int) from Int to Int {
    public static inline var Unknown:PropertyID = cast 0;
    public static inline var Alignment_Baseline:PropertyID = cast 1;
    public static inline var Baseline_Shift:PropertyID = cast 2;
    public static inline var Class:PropertyID = cast 3;
    public static inline var Clip_Path:PropertyID = cast 4;
    public static inline var Clip_Rule:PropertyID = cast 5;
    public static inline var ClipPathUnits:PropertyID = cast 6;
    public static inline var Color:PropertyID = cast 7;
    public static inline var Cx:PropertyID = cast 8;
    public static inline var Cy:PropertyID = cast 9;
    public static inline var D:PropertyID = cast 10;
    public static inline var Direction:PropertyID = cast 11;
    public static inline var Display:PropertyID = cast 12;
    public static inline var Dominant_Baseline:PropertyID = cast 13;
    public static inline var Dx:PropertyID = cast 14;
    public static inline var Dy:PropertyID = cast 15;
    public static inline var Fill:PropertyID = cast 16;
    public static inline var Fill_Opacity:PropertyID = cast 17;
    public static inline var Fill_Rule:PropertyID = cast 18;
    public static inline var Font_Family:PropertyID = cast 19;
    public static inline var Font_Size:PropertyID = cast 20;
    public static inline var Font_Style:PropertyID = cast 21;
    public static inline var Font_Weight:PropertyID = cast 22;
    public static inline var Fx:PropertyID = cast 23;
    public static inline var Fy:PropertyID = cast 24;
    public static inline var GradientTransform:PropertyID = cast 25;
    public static inline var GradientUnits:PropertyID = cast 26;
    public static inline var Height:PropertyID = cast 27;
    public static inline var Href:PropertyID = cast 28;
    public static inline var Id:PropertyID = cast 29;
    public static inline var LengthAdjust:PropertyID = cast 30;
    public static inline var Letter_Spacing:PropertyID = cast 31;
    public static inline var Marker_End:PropertyID = cast 32;
    public static inline var Marker_Mid:PropertyID = cast 33;
    public static inline var Marker_Start:PropertyID = cast 34;
    public static inline var MarkerHeight:PropertyID = cast 35;
    public static inline var MarkerUnits:PropertyID = cast 36;
    public static inline var MarkerWidth:PropertyID = cast 37;
    public static inline var Mask:PropertyID = cast 38;
    public static inline var Mask_Type:PropertyID = cast 39;
    public static inline var MaskContentUnits:PropertyID = cast 40;
    public static inline var MaskUnits:PropertyID = cast 41;
    public static inline var Offset:PropertyID = cast 42;
    public static inline var Opacity:PropertyID = cast 43;
    public static inline var Orient:PropertyID = cast 44;
    public static inline var Overflow:PropertyID = cast 45;
    public static inline var PatternContentUnits:PropertyID = cast 46;
    public static inline var PatternTransform:PropertyID = cast 47;
    public static inline var PatternUnits:PropertyID = cast 48;
    public static inline var Pointer_Events:PropertyID = cast 49;
    public static inline var Points:PropertyID = cast 50;
    public static inline var PreserveAspectRatio:PropertyID = cast 51;
    public static inline var R:PropertyID = cast 52;
    public static inline var RefX:PropertyID = cast 53;
    public static inline var RefY:PropertyID = cast 54;
    public static inline var Rotate:PropertyID = cast 55;
    public static inline var Rx:PropertyID = cast 56;
    public static inline var Ry:PropertyID = cast 57;
    public static inline var SpreadMethod:PropertyID = cast 58;
    public static inline var Stop_Color:PropertyID = cast 59;
    public static inline var Stop_Opacity:PropertyID = cast 60;
    public static inline var Stroke:PropertyID = cast 61;
    public static inline var Stroke_Dasharray:PropertyID = cast 62;
    public static inline var Stroke_Dashoffset:PropertyID = cast 63;
    public static inline var Stroke_Linecap:PropertyID = cast 64;
    public static inline var Stroke_Linejoin:PropertyID = cast 65;
    public static inline var Stroke_Miterlimit:PropertyID = cast 66;
    public static inline var Stroke_Opacity:PropertyID = cast 67;
    public static inline var Stroke_Width:PropertyID = cast 68;
    public static inline var Style:PropertyID = cast 69;
    public static inline var Text_Anchor:PropertyID = cast 70;
    public static inline var Text_Orientation:PropertyID = cast 71;
    public static inline var TextLength:PropertyID = cast 72;
    public static inline var Transform:PropertyID = cast 73;
    public static inline var ViewBox:PropertyID = cast 74;
    public static inline var Visibility:PropertyID = cast 75;
    public static inline var White_Space:PropertyID = cast 76;
    public static inline var Width:PropertyID = cast 77;
    public static inline var Word_Spacing:PropertyID = cast 78;
    public static inline var Writing_Mode:PropertyID = cast 79;
    public static inline var X:PropertyID = cast 80;
    public static inline var X1:PropertyID = cast 81;
    public static inline var X2:PropertyID = cast 82;
    public static inline var Y:PropertyID = cast 83;
    public static inline var Y1:PropertyID = cast 84;
    public static inline var Y2:PropertyID = cast 85;
}

/**
 * Name to `PropertyID` tables (`propertyid()`, `csspropertyid()`).
 */
class PropertyIds {

    static var attributeTable:Null<Map<String, PropertyID>> = null;

    static var cssTable:Null<Map<String, PropertyID>> = null;

    public static function propertyid(name:String):PropertyID {
        if (attributeTable == null) {
            var t = new Map<String, PropertyID>();
            t.set("class", PropertyID.Class);
            t.set("clipPathUnits", PropertyID.ClipPathUnits);
            t.set("cx", PropertyID.Cx);
            t.set("cy", PropertyID.Cy);
            t.set("d", PropertyID.D);
            t.set("dx", PropertyID.Dx);
            t.set("dy", PropertyID.Dy);
            t.set("fx", PropertyID.Fx);
            t.set("fy", PropertyID.Fy);
            t.set("gradientTransform", PropertyID.GradientTransform);
            t.set("gradientUnits", PropertyID.GradientUnits);
            t.set("height", PropertyID.Height);
            t.set("href", PropertyID.Href);
            t.set("id", PropertyID.Id);
            t.set("lengthAdjust", PropertyID.LengthAdjust);
            t.set("markerHeight", PropertyID.MarkerHeight);
            t.set("markerUnits", PropertyID.MarkerUnits);
            t.set("markerWidth", PropertyID.MarkerWidth);
            t.set("maskContentUnits", PropertyID.MaskContentUnits);
            t.set("maskUnits", PropertyID.MaskUnits);
            t.set("offset", PropertyID.Offset);
            t.set("orient", PropertyID.Orient);
            t.set("patternContentUnits", PropertyID.PatternContentUnits);
            t.set("patternTransform", PropertyID.PatternTransform);
            t.set("patternUnits", PropertyID.PatternUnits);
            t.set("points", PropertyID.Points);
            t.set("preserveAspectRatio", PropertyID.PreserveAspectRatio);
            t.set("r", PropertyID.R);
            t.set("refX", PropertyID.RefX);
            t.set("refY", PropertyID.RefY);
            t.set("rotate", PropertyID.Rotate);
            t.set("rx", PropertyID.Rx);
            t.set("ry", PropertyID.Ry);
            t.set("spreadMethod", PropertyID.SpreadMethod);
            t.set("style", PropertyID.Style);
            t.set("textLength", PropertyID.TextLength);
            t.set("transform", PropertyID.Transform);
            t.set("viewBox", PropertyID.ViewBox);
            t.set("width", PropertyID.Width);
            t.set("x", PropertyID.X);
            t.set("x1", PropertyID.X1);
            t.set("x2", PropertyID.X2);
            t.set("xlink:href", PropertyID.Href);
            t.set("xml:space", PropertyID.White_Space);
            t.set("y", PropertyID.Y);
            t.set("y1", PropertyID.Y1);
            t.set("y2", PropertyID.Y2);
            attributeTable = t;
        }

        var id = attributeTable.get(name);
        if (id == null)
            return csspropertyid(name);
        return id;
    }

    public static function csspropertyid(name:String):PropertyID {
        if (cssTable == null) {
            var t = new Map<String, PropertyID>();
            t.set("alignment-baseline", PropertyID.Alignment_Baseline);
            t.set("baseline-shift", PropertyID.Baseline_Shift);
            t.set("clip-path", PropertyID.Clip_Path);
            t.set("clip-rule", PropertyID.Clip_Rule);
            t.set("color", PropertyID.Color);
            t.set("direction", PropertyID.Direction);
            t.set("display", PropertyID.Display);
            t.set("dominant-baseline", PropertyID.Dominant_Baseline);
            t.set("fill", PropertyID.Fill);
            t.set("fill-opacity", PropertyID.Fill_Opacity);
            t.set("fill-rule", PropertyID.Fill_Rule);
            t.set("font-family", PropertyID.Font_Family);
            t.set("font-size", PropertyID.Font_Size);
            t.set("font-style", PropertyID.Font_Style);
            t.set("font-weight", PropertyID.Font_Weight);
            t.set("letter-spacing", PropertyID.Letter_Spacing);
            t.set("marker-end", PropertyID.Marker_End);
            t.set("marker-mid", PropertyID.Marker_Mid);
            t.set("marker-start", PropertyID.Marker_Start);
            t.set("mask", PropertyID.Mask);
            t.set("mask-type", PropertyID.Mask_Type);
            t.set("opacity", PropertyID.Opacity);
            t.set("overflow", PropertyID.Overflow);
            t.set("pointer-events", PropertyID.Pointer_Events);
            t.set("stop-color", PropertyID.Stop_Color);
            t.set("stop-opacity", PropertyID.Stop_Opacity);
            t.set("stroke", PropertyID.Stroke);
            t.set("stroke-dasharray", PropertyID.Stroke_Dasharray);
            t.set("stroke-dashoffset", PropertyID.Stroke_Dashoffset);
            t.set("stroke-linecap", PropertyID.Stroke_Linecap);
            t.set("stroke-linejoin", PropertyID.Stroke_Linejoin);
            t.set("stroke-miterlimit", PropertyID.Stroke_Miterlimit);
            t.set("stroke-opacity", PropertyID.Stroke_Opacity);
            t.set("stroke-width", PropertyID.Stroke_Width);
            t.set("text-anchor", PropertyID.Text_Anchor);
            t.set("text-orientation", PropertyID.Text_Orientation);
            t.set("visibility", PropertyID.Visibility);
            t.set("white-space", PropertyID.White_Space);
            t.set("word-spacing", PropertyID.Word_Spacing);
            t.set("writing-mode", PropertyID.Writing_Mode);
            cssTable = t;
        }

        var id = cssTable.get(name);
        if (id == null)
            return PropertyID.Unknown;
        return id;
    }

}

/**
 * Base class of the typed attribute values of an element (`SVGProperty`).
 */
class SVGProperty {

    var m_id:PropertyID;

    public function new(id:PropertyID) {
        m_id = id;
    }

    public inline function id():PropertyID {
        return m_id;
    }

    public function parse(input:StringView):Bool {
        return false;
    }

}

class SVGString extends SVGProperty {

    var m_value:String = "";

    public function new(id:PropertyID) {
        super(id);
    }

    public inline function value():String {
        return m_value;
    }

    override public function parse(input:StringView):Bool {
        stripLeadingAndTrailingSpaces(input);
        m_value = input.toString();
        return true;
    }

}

/**
 * A paint reference: an optional paint server id and a color (`Paint` in
 * svgproperty.h).
 */
class Paint {

    var m_id:String;

    var m_color:Color;

    public function new(id:String = "", ?color:Color) {
        m_id = id;
        m_color = color != null ? color : Color.Transparent;
    }

    public static inline function ofColor(color:Color):Paint {
        return new Paint("", color);
    }

    public inline function color():Color {
        return m_color;
    }

    public inline function id():String {
        return m_id;
    }

    public inline function isNone():Bool {
        return m_id.length == 0 && !m_color.isVisible();
    }

}

enum abstract Display(Int) from Int to Int {
    var Inline;
    var None;
}

enum abstract Visibility(Int) from Int to Int {
    var Visible;
    var Hidden;
    var Collapse;
}

enum abstract Overflow(Int) from Int to Int {
    var Visible;
    var Hidden;
}

enum abstract PointerEvents(Int) from Int to Int {
    var None;
    var Auto;
    var Stroke;
    var Fill;
    var Painted;
    var Visible;
    var VisibleStroke;
    var VisibleFill;
    var VisiblePainted;
    var BoundingBox;
    var All;
}

enum abstract FontStyle(Int) from Int to Int {
    var Normal;
    var Italic;
}

enum abstract FontWeight(Int) from Int to Int {
    var Normal;
    var Bold;
}

enum abstract AlignmentBaseline(Int) from Int to Int {
    var Auto;
    var Baseline;
    var BeforeEdge;
    var TextBeforeEdge;
    var Middle;
    var Central;
    var AfterEdge;
    var TextAfterEdge;
    var Ideographic;
    var Alphabetic;
    var Hanging;
    var Mathematical;
}

enum abstract DominantBaseline(Int) from Int to Int {
    var Auto;
    var UseScript;
    var NoChange;
    var ResetSize;
    var Ideographic;
    var Alphabetic;
    var Hanging;
    var Mathematical;
    var Central;
    var Middle;
    var TextAfterEdge;
    var TextBeforeEdge;
}

enum abstract TextAnchor(Int) from Int to Int {
    var Start;
    var Middle;
    var End;
}

enum abstract WhiteSpace(Int) from Int to Int {
    var Default;
    var Preserve;
}

enum abstract WritingMode(Int) from Int to Int {
    var Horizontal;
    var Vertical;
}

enum abstract TextOrientation(Int) from Int to Int {
    var Mixed;
    var Upright;
}

enum abstract Direction(Int) from Int to Int {
    var Ltr;
    var Rtl;
}

enum abstract MaskType(Int) from Int to Int {
    var Luminance;
    var Alpha;
}

enum abstract Units(Int) from Int to Int {
    var UserSpaceOnUse;
    var ObjectBoundingBox;
}

enum abstract MarkerUnits(Int) from Int to Int {
    var StrokeWidth;
    var UserSpaceOnUse;
}

enum abstract LengthAdjust(Int) from Int to Int {
    var Spacing;
    var SpacingAndGlyphs;
}

/**
 * An enumerated attribute (`SVGEnumeration<Enum>`). Values are stored as
 * Int, entries map keywords to values.
 */
class SVGEnumeration extends SVGProperty {

    public static final SPREAD_METHOD_ENTRIES:Array<SVGEnumerationEntry> = [
        new SVGEnumerationEntry((plutovg.SpreadMethod.Pad : Int), "pad"),
        new SVGEnumerationEntry((plutovg.SpreadMethod.Reflect : Int), "reflect"),
        new SVGEnumerationEntry((plutovg.SpreadMethod.Repeat : Int), "repeat")
    ];

    public static final UNITS_ENTRIES:Array<SVGEnumerationEntry> = [
        new SVGEnumerationEntry((Units.UserSpaceOnUse : Int), "userSpaceOnUse"),
        new SVGEnumerationEntry((Units.ObjectBoundingBox : Int), "objectBoundingBox")
    ];

    public static final MARKER_UNITS_ENTRIES:Array<SVGEnumerationEntry> = [
        new SVGEnumerationEntry((MarkerUnits.StrokeWidth : Int), "strokeWidth"),
        new SVGEnumerationEntry((MarkerUnits.UserSpaceOnUse : Int), "userSpaceOnUse")
    ];

    public static final LENGTH_ADJUST_ENTRIES:Array<SVGEnumerationEntry> = [
        new SVGEnumerationEntry((LengthAdjust.Spacing : Int), "spacing"),
        new SVGEnumerationEntry((LengthAdjust.SpacingAndGlyphs : Int), "spacingAndGlyphs")
    ];

    var m_value:Int;

    var m_entries:Array<SVGEnumerationEntry>;

    public function new(id:PropertyID, value:Int, entries:Array<SVGEnumerationEntry>) {
        super(id);
        m_value = value;
        m_entries = entries;
    }

    public inline function value():Int {
        return m_value;
    }

    override public function parse(input:StringView):Bool {
        stripLeadingAndTrailingSpaces(input);
        for (entry in m_entries) {
            if (input.equals(entry.name)) {
                m_value = entry.value;
                return true;
            }
        }

        return false;
    }

}

class SVGEnumerationEntry {

    public var value:Int;

    public var name:String;

    public function new(value:Int, name:String) {
        this.value = value;
        this.name = name;
    }

}

enum abstract OrientType(Int) from Int to Int {
    var Auto;
    var AutoStartReverse;
    var Angle;
}

class SVGAngle extends SVGProperty {

    var m_value:Float = 0;

    var m_orientType:OrientType = Angle;

    public function new(id:PropertyID) {
        super(id);
    }

    public inline function value():Float {
        return m_value;
    }

    public inline function orientType():OrientType {
        return m_orientType;
    }

    override public function parse(input:StringView):Bool {
        stripLeadingAndTrailingSpaces(input);
        if (input.equals("auto")) {
            m_value = 0;
            m_orientType = Auto;
            return true;
        }

        if (input.equals("auto-start-reverse")) {
            m_value = 0;
            m_orientType = AutoStartReverse;
            return true;
        }

        var value = parseNumber(input);
        if (Math.isNaN(value))
            return false;
        if (!input.empty()) {
            if (input.equals("rad"))
                value = f32(value * f32(180 / plutovg.Plutovg.PI));
            else if (input.equals("grad"))
                value = f32(value * f32(360 / 400));
            else if (input.equals("turn"))
                value = f32(value * 360);
            else if (!input.equals("deg")) {
                return false;
            }
        }

        m_value = value;
        m_orientType = Angle;
        return true;
    }

}

enum abstract LengthUnits(Int) from Int to Int {
    var None;
    var Percent;
    var Px;
    var Em;
    var Ex;
}

enum abstract LengthDirection(Int) from Int to Int {
    var Horizontal;
    var Vertical;
    var Diagonal;
}

enum abstract LengthNegativeMode(Int) from Int to Int {
    var Allow;
    var Forbid;
}

/**
 * A length with units (`Length`). Mutable through `parse()`.
 */
class Length {

    var m_value:Float = 0;

    var m_units:LengthUnits = None;

    public function new(value:Float = 0, units:LengthUnits = None) {
        m_value = f32(value);
        m_units = units;
    }

    public inline function clone():Length {
        return new Length(m_value, m_units);
    }

    public inline function value():Float {
        return m_value;
    }

    public inline function units():LengthUnits {
        return m_units;
    }

    public function parse(input:StringView, mode:LengthNegativeMode):Bool {
        stripLeadingAndTrailingSpaces(input);
        var value = parseNumber(input);
        if (Math.isNaN(value))
            return false;
        if (value < 0 && mode == Forbid)
            return false;
        if (input.empty()) {
            m_value = value;
            m_units = None;
            return true;
        }

        final dpi = 96.0;
        switch (input.front()) {
            case '%'.code:
                m_value = value;
                m_units = Percent;
                input.removePrefix(1);
            case 'p'.code:
                input.removePrefix(1);
                if (input.empty())
                    return false;
                else if (input.front() == 'x'.code)
                    m_value = value;
                else if (input.front() == 'c'.code)
                    m_value = f32(f32(value * dpi) / 6);
                else if (input.front() == 't'.code)
                    m_value = f32(f32(value * dpi) / 72);
                else
                    return false;
                m_units = Px;
                input.removePrefix(1);
            case 'i'.code:
                input.removePrefix(1);
                if (input.empty())
                    return false;
                else if (input.front() == 'n'.code)
                    m_value = f32(value * dpi);
                else
                    return false;
                m_units = Px;
                input.removePrefix(1);
            case 'c'.code:
                input.removePrefix(1);
                if (input.empty())
                    return false;
                else if (input.front() == 'm'.code)
                    m_value = f32(f32(value * dpi) / f32(2.54));
                else
                    return false;
                m_units = Px;
                input.removePrefix(1);
            case 'm'.code:
                input.removePrefix(1);
                if (input.empty())
                    return false;
                else if (input.front() == 'm'.code)
                    m_value = f32(f32(value * dpi) / f32(25.4));
                else
                    return false;
                m_units = Px;
                input.removePrefix(1);
            case 'e'.code:
                input.removePrefix(1);
                if (input.empty())
                    return false;
                else if (input.front() == 'm'.code)
                    m_units = Em;
                else if (input.front() == 'x'.code)
                    m_units = Ex;
                else
                    return false;
                m_value = value;
                input.removePrefix(1);
            default:
                return false;
        }

        return input.empty();
    }

}

class SVGLength extends SVGProperty {

    var m_direction:LengthDirection;

    var m_negativeMode:LengthNegativeMode;

    var m_value:Length;

    public function new(id:PropertyID, direction:LengthDirection, negativeMode:LengthNegativeMode, value:Float = 0, units:LengthUnits = None) {
        super(id);
        m_direction = direction;
        m_negativeMode = negativeMode;
        m_value = new Length(value, units);
    }

    public inline function isPercent():Bool {
        return m_value.units() == Percent;
    }

    public inline function direction():LengthDirection {
        return m_direction;
    }

    public inline function negativeMode():LengthNegativeMode {
        return m_negativeMode;
    }

    public inline function value():Length {
        return m_value;
    }

    override public function parse(input:StringView):Bool {
        return m_value.parse(input, m_negativeMode);
    }

}

/**
 * Resolves lengths to user units for an element (`LengthContext`).
 */
class LengthContext {

    var m_element:SVGElement;

    var m_units:Units;

    public function new(element:SVGElement, units:Units = UserSpaceOnUse) {
        m_element = element;
        m_units = units;
    }

    public function valueForLength(length:Length, direction:LengthDirection):Float {
        if (length.units() == Percent) {
            if (m_units == UserSpaceOnUse)
                return f32(f32(length.value() * viewportDimension(direction)) / 100);
            return f32(length.value() / 100);
        }

        if (length.units() == Ex)
            return f32(f32(length.value() * m_element.fontSize()) / 2);
        if (length.units() == Em)
            return f32(length.value() * m_element.fontSize());
        return length.value();
    }

    public inline function valueForSVGLength(length:SVGLength):Float {
        return valueForLength(length.value(), length.direction());
    }

    function viewportDimension(direction:LengthDirection):Float {
        var viewportSize = m_element.currentViewportSize();
        switch (direction) {
            case Horizontal:
                return viewportSize.w;
            case Vertical:
                return viewportSize.h;
            default:
                return f32(f32(Math.sqrt(f32(f32(viewportSize.w * viewportSize.w) + f32(viewportSize.h * viewportSize.h)))) / plutovg.Plutovg.SQRT2);
        }
    }

}

typedef LengthList = Array<Length>;

class SVGLengthList extends SVGProperty {

    var m_direction:LengthDirection;

    var m_negativeMode:LengthNegativeMode;

    var m_values:LengthList = [];

    public function new(id:PropertyID, direction:LengthDirection, negativeMode:LengthNegativeMode) {
        super(id);
        m_direction = direction;
        m_negativeMode = negativeMode;
    }

    public inline function direction():LengthDirection {
        return m_direction;
    }

    public inline function negativeMode():LengthNegativeMode {
        return m_negativeMode;
    }

    public inline function values():LengthList {
        return m_values;
    }

    override public function parse(input:StringView):Bool {
        m_values = [];
        while (!input.empty()) {
            var count = 0;
            while (count < input.length() && input.at(count) != ','.code && !IS_WS(input.at(count)))
                ++count;
            if (count == 0)
                break;
            var value = new Length(0, None);
            if (!value.parse(input.substr(0, count), m_negativeMode))
                return false;
            input.removePrefix(count);
            skipOptionalSpacesOrComma(input);
            m_values.push(value);
        }

        return true;
    }

}

enum abstract BaselineShiftType(Int) from Int to Int {
    var Baseline;
    var Sub;
    var Super;
    var Length;
}

class BaselineShift {

    var m_type:BaselineShiftType = Baseline;

    var m_length:Length;

    public function new(type:BaselineShiftType = Baseline, ?length:Length) {
        m_type = type;
        m_length = length != null ? length : new Length();
    }

    public static inline function ofLength(length:Length):BaselineShift {
        return new BaselineShift(BaselineShiftType.Length, length);
    }

    public inline function type():BaselineShiftType {
        return m_type;
    }

    public inline function length():Length {
        return m_length;
    }

}

class SVGNumber extends SVGProperty {

    var m_value:Float;

    public function new(id:PropertyID, value:Float) {
        super(id);
        m_value = f32(value);
    }

    public inline function value():Float {
        return m_value;
    }

    override public function parse(input:StringView):Bool {
        stripLeadingAndTrailingSpaces(input);
        var value = parseNumber(input);
        if (Math.isNaN(value))
            return false;
        if (!input.empty())
            return false;
        m_value = value;
        return true;
    }

}

class SVGNumberPercentage extends SVGProperty {

    var m_value:Float;

    public function new(id:PropertyID, value:Float) {
        super(id);
        m_value = f32(value);
    }

    public inline function value():Float {
        return m_value;
    }

    override public function parse(input:StringView):Bool {
        stripLeadingAndTrailingSpaces(input);
        var value = parseNumber(input);
        if (Math.isNaN(value))
            return false;
        if (!input.empty() && input.front() == '%'.code) {
            value = f32(value / 100);
            input.removePrefix(1);
        }

        if (!input.empty())
            return false;
        m_value = value < 0 ? 0 : (value > 1 ? 1 : value);
        return true;
    }

}

typedef NumberList = Array<Float>;

class SVGNumberList extends SVGProperty {

    var m_values:NumberList = [];

    public function new(id:PropertyID) {
        super(id);
    }

    public inline function values():NumberList {
        return m_values;
    }

    override public function parse(input:StringView):Bool {
        m_values = [];
        stripLeadingSpaces(input);
        while (!input.empty()) {
            var value = parseNumber(input);
            if (Math.isNaN(value))
                return false;
            skipOptionalSpacesOrComma(input);
            m_values.push(value);
        }

        return true;
    }

}

class SVGPath extends SVGProperty {

    var m_value:lunasvg.Graphics.Path = new lunasvg.Graphics.Path();

    public function new(id:PropertyID) {
        super(id);
    }

    public inline function value():lunasvg.Graphics.Path {
        return m_value;
    }

    override public function parse(input:StringView):Bool {
        return m_value.parse(input.toString());
    }

}

class SVGPoint extends SVGProperty {

    var m_value:Point = new Point();

    public function new(id:PropertyID) {
        super(id);
    }

    public inline function value():Point {
        return m_value;
    }

    override public function parse(input:StringView):Bool {
        stripLeadingAndTrailingSpaces(input);
        var x = parseNumber(input);
        if (Math.isNaN(x) || !skipOptionalSpaces(input))
            return false;
        var y = parseNumber(input);
        if (Math.isNaN(y) || !input.empty())
            return false;
        m_value = new Point(x, y);
        return true;
    }

}

typedef PointList = Array<Point>;

class SVGPointList extends SVGProperty {

    var m_values:PointList = [];

    public function new(id:PropertyID) {
        super(id);
    }

    public inline function values():PointList {
        return m_values;
    }

    override public function parse(input:StringView):Bool {
        m_values = [];
        stripLeadingSpaces(input);
        while (!input.empty()) {
            var x = parseNumber(input);
            if (Math.isNaN(x) || !skipOptionalSpacesOrComma(input))
                return false;
            var y = parseNumber(input);
            if (Math.isNaN(y))
                return false;
            m_values.push(new Point(x, y));
            skipOptionalSpacesOrComma(input);
        }

        return true;
    }

}

class SVGRect extends SVGProperty {

    var m_value:Rect = Rect.invalid();

    public function new(id:PropertyID) {
        super(id);
    }

    public inline function value():Rect {
        return m_value;
    }

    override public function parse(input:StringView):Bool {
        stripLeadingAndTrailingSpaces(input);
        var x = parseNumber(input);
        if (Math.isNaN(x) || !skipOptionalSpacesOrComma(input))
            return false;
        var y = parseNumber(input);
        if (Math.isNaN(y) || !skipOptionalSpacesOrComma(input))
            return false;
        var w = parseNumber(input);
        if (Math.isNaN(w) || !skipOptionalSpacesOrComma(input))
            return false;
        var h = parseNumber(input);
        if (Math.isNaN(h) || !input.empty())
            return false;
        if (w < 0 || h < 0)
            return false;
        m_value = new Rect(x, y, w, h);
        return true;
    }

}

class SVGTransform extends SVGProperty {

    var m_value:lunasvg.Graphics.Transform = new lunasvg.Graphics.Transform();

    public function new(id:PropertyID) {
        super(id);
    }

    public inline function value():lunasvg.Graphics.Transform {
        return m_value;
    }

    override public function parse(input:StringView):Bool {
        return m_value.parse(input.toString());
    }

}

enum abstract AlignType(Int) from Int to Int {
    var None;
    var xMinYMin;
    var xMidYMin;
    var xMaxYMin;
    var xMinYMid;
    var xMidYMid;
    var xMaxYMid;
    var xMinYMax;
    var xMidYMax;
    var xMaxYMax;
}

enum abstract MeetOrSlice(Int) from Int to Int {
    var Meet;
    var Slice;
}

class SVGPreserveAspectRatio extends SVGProperty {

    var m_alignType:AlignType = xMidYMid;

    var m_meetOrSlice:MeetOrSlice = Meet;

    public function new(id:PropertyID) {
        super(id);
    }

    public inline function alignType():AlignType {
        return m_alignType;
    }

    public inline function meetOrSlice():MeetOrSlice {
        return m_meetOrSlice;
    }

    override public function parse(input:StringView):Bool {
        var alignType:AlignType = xMidYMid;
        stripLeadingSpaces(input);
        if (skipString(input, "none"))
            alignType = None;
        else if (skipString(input, "xMinYMin"))
            alignType = xMinYMin;
        else if (skipString(input, "xMidYMin"))
            alignType = xMidYMin;
        else if (skipString(input, "xMaxYMin"))
            alignType = xMaxYMin;
        else if (skipString(input, "xMinYMid"))
            alignType = xMinYMid;
        else if (skipString(input, "xMidYMid"))
            alignType = xMidYMid;
        else if (skipString(input, "xMaxYMid"))
            alignType = xMaxYMid;
        else if (skipString(input, "xMinYMax"))
            alignType = xMinYMax;
        else if (skipString(input, "xMidYMax"))
            alignType = xMidYMax;
        else if (skipString(input, "xMaxYMax"))
            alignType = xMaxYMax;
        else {
            return false;
        }

        var meetOrSlice:MeetOrSlice = Meet;
        skipOptionalSpaces(input);
        if (skipString(input, "meet")) {
            meetOrSlice = Meet;
        } else if (skipString(input, "slice")) {
            meetOrSlice = Slice;
        }

        if (alignType == None)
            meetOrSlice = Meet;
        skipOptionalSpaces(input);
        if (!input.empty())
            return false;
        m_alignType = alignType;
        m_meetOrSlice = meetOrSlice;
        return true;
    }

    public function getClipRect(viewBoxRect:Rect, viewportSize:Size):Rect {
        var xScale = f32(viewportSize.w / viewBoxRect.w);
        var yScale = f32(viewportSize.h / viewBoxRect.h);
        if (m_alignType == None) {
            return new Rect(viewBoxRect.x, viewBoxRect.y, viewportSize.w / xScale, viewportSize.h / yScale);
        }

        var scale = (m_meetOrSlice == Meet) ? Math.min(xScale, yScale) : Math.max(xScale, yScale);
        var xOffset = f32(-viewBoxRect.x * scale);
        var yOffset = f32(-viewBoxRect.y * scale);
        var viewWidth = f32(viewBoxRect.w * scale);
        var viewHeight = f32(viewBoxRect.h * scale);
        switch (m_alignType) {
            case xMidYMin | xMidYMid | xMidYMax:
                xOffset = f32(xOffset + f32(f32(viewportSize.w - viewWidth) * 0.5));
            case xMaxYMin | xMaxYMid | xMaxYMax:
                xOffset = f32(xOffset + f32(viewportSize.w - viewWidth));
            default:
        }

        switch (m_alignType) {
            case xMinYMid | xMidYMid | xMaxYMid:
                yOffset = f32(yOffset + f32(f32(viewportSize.h - viewHeight) * 0.5));
            case xMinYMax | xMidYMax | xMaxYMax:
                yOffset = f32(yOffset + f32(viewportSize.h - viewHeight));
            default:
        }

        return new Rect(-xOffset / scale, -yOffset / scale, viewportSize.w / scale, viewportSize.h / scale);
    }

    public function getTransform(viewBoxRect:Rect, viewportSize:Size):lunasvg.Graphics.Transform {
        var xScale = f32(viewportSize.w / viewBoxRect.w);
        var yScale = f32(viewportSize.h / viewBoxRect.h);
        if (m_alignType == None) {
            return new lunasvg.Graphics.Transform(xScale, 0, 0, yScale, f32(-viewBoxRect.x * xScale), f32(-viewBoxRect.y * yScale));
        }

        var scale = (m_meetOrSlice == Meet) ? Math.min(xScale, yScale) : Math.max(xScale, yScale);
        var xOffset = f32(-viewBoxRect.x * scale);
        var yOffset = f32(-viewBoxRect.y * scale);
        var viewWidth = f32(viewBoxRect.w * scale);
        var viewHeight = f32(viewBoxRect.h * scale);
        switch (m_alignType) {
            case xMidYMin | xMidYMid | xMidYMax:
                xOffset = f32(xOffset + f32(f32(viewportSize.w - viewWidth) * 0.5));
            case xMaxYMin | xMaxYMid | xMaxYMax:
                xOffset = f32(xOffset + f32(viewportSize.w - viewWidth));
            default:
        }

        switch (m_alignType) {
            case xMinYMid | xMidYMid | xMaxYMid:
                yOffset = f32(yOffset + f32(f32(viewportSize.h - viewHeight) * 0.5));
            case xMinYMax | xMidYMax | xMaxYMax:
                yOffset = f32(yOffset + f32(viewportSize.h - viewHeight));
            default:
        }

        return new lunasvg.Graphics.Transform(scale, 0, 0, scale, xOffset, yOffset);
    }

    /**
     * Adjusts `dstRect` and `srcRect` in place to fit an image.
     */
    public function transformRect(dstRect:Rect, srcRect:Rect):Void {
        if (m_alignType == None)
            return;
        var viewSize = dstRect.size();
        var imageSize = srcRect.size();
        if (m_meetOrSlice == Meet) {
            var scale = f32(imageSize.h / imageSize.w);
            if (viewSize.h > f32(viewSize.w * scale)) {
                dstRect.h = f32(viewSize.w * scale);
                switch (m_alignType) {
                    case xMinYMid | xMidYMid | xMaxYMid:
                        dstRect.y = f32(dstRect.y + f32(f32(viewSize.h - dstRect.h) * 0.5));
                    case xMinYMax | xMidYMax | xMaxYMax:
                        dstRect.y = f32(dstRect.y + f32(viewSize.h - dstRect.h));
                    default:
                }
            }

            if (viewSize.w > f32(viewSize.h / scale)) {
                dstRect.w = f32(viewSize.h / scale);
                switch (m_alignType) {
                    case xMidYMin | xMidYMid | xMidYMax:
                        dstRect.x = f32(dstRect.x + f32(f32(viewSize.w - dstRect.w) * 0.5));
                    case xMaxYMin | xMaxYMid | xMaxYMax:
                        dstRect.x = f32(dstRect.x + f32(viewSize.w - dstRect.w));
                    default:
                }
            }
        } else if (m_meetOrSlice == Slice) {
            var scale = f32(imageSize.h / imageSize.w);
            if (viewSize.h < f32(viewSize.w * scale)) {
                srcRect.h = f32(viewSize.h * f32(imageSize.w / viewSize.w));
                switch (m_alignType) {
                    case xMinYMid | xMidYMid | xMaxYMid:
                        srcRect.y = f32(srcRect.y + f32(f32(imageSize.h - srcRect.h) * 0.5));
                    case xMinYMax | xMidYMax | xMaxYMax:
                        srcRect.y = f32(srcRect.y + f32(imageSize.h - srcRect.h));
                    default:
                }
            }

            if (viewSize.w < f32(viewSize.h / scale)) {
                srcRect.w = f32(viewSize.w * f32(imageSize.h / viewSize.h));
                switch (m_alignType) {
                    case xMidYMin | xMidYMid | xMidYMax:
                        srcRect.x = f32(srcRect.x + f32(f32(imageSize.w - srcRect.w) * 0.5));
                    case xMaxYMin | xMaxYMid | xMaxYMax:
                        srcRect.x = f32(srcRect.x + f32(imageSize.w - srcRect.w));
                    default:
                }
            }
        }
    }

}
