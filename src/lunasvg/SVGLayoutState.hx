// Ported from lunasvg 3.5.0: source/svglayoutstate.h, source/svglayoutstate.cpp
// Original code Copyright (c) 2020-2026 Samuel Ugochukwu, licensed under MIT.
// Modified: translated from C++ to Haxe. See LICENSE.
package lunasvg;

import lunasvg.Graphics;
import lunasvg.SVGElement;
import lunasvg.SVGParserUtils;
import lunasvg.SVGParserUtils.SVGParserUtils.*;
import lunasvg.SVGProperty;
import plutovg.Utils.f32;

/**
 * The computed style of an element during layout (`SVGLayoutState`).
 * Inherited properties are copied from the parent state, then the
 * presentation attributes of the element are applied.
 */
class SVGLayoutState {

    var m_parent:Null<SVGLayoutState> = null;

    var m_element:Null<SVGElement> = null;

    var m_fill:lunasvg.SVGProperty.Paint = lunasvg.SVGProperty.Paint.ofColor(lunasvg.Graphics.Color.Black);

    var m_stroke:lunasvg.SVGProperty.Paint = lunasvg.SVGProperty.Paint.ofColor(lunasvg.Graphics.Color.Transparent);

    var m_color:lunasvg.Graphics.Color = lunasvg.Graphics.Color.Black;

    var m_stop_color:lunasvg.Graphics.Color = lunasvg.Graphics.Color.Black;

    var m_opacity:Float = 1;

    var m_fill_opacity:Float = 1;

    var m_stroke_opacity:Float = 1;

    var m_stop_opacity:Float = 1;

    var m_stroke_miterlimit:Float = 4;

    var m_font_size:Float = 12;

    var m_letter_spacing:Length = new Length(0, None);

    var m_word_spacing:Length = new Length(0, None);

    var m_baseline_shift:BaselineShift = new BaselineShift();

    var m_stroke_width:Length = new Length(1, None);

    var m_stroke_dashoffset:Length = new Length(0, None);

    var m_stroke_dasharray:LengthList = [];

    var m_stroke_linecap:LineCap = Butt;

    var m_stroke_linejoin:LineJoin = Miter;

    var m_fill_rule:FillRule = NonZero;

    var m_clip_rule:FillRule = NonZero;

    var m_font_weight:FontWeight = Normal;

    var m_font_style:FontStyle = Normal;

    var m_alignment_baseline:AlignmentBaseline = Auto;

    var m_dominant_baseline:DominantBaseline = Auto;

    var m_text_anchor:TextAnchor = Start;

    var m_white_space:WhiteSpace = Default;

    var m_writing_mode:WritingMode = Horizontal;

    var m_text_orientation:TextOrientation = Mixed;

    var m_direction:Direction = Ltr;

    var m_display:Display = Inline;

    var m_visibility:Visibility = Visible;

    var m_overflow:Overflow = Visible;

    var m_pointer_events:PointerEvents = Auto;

    var m_mask_type:MaskType = Luminance;

    var m_mask:String = "";

    var m_clip_path:String = "";

    var m_marker_start:String = "";

    var m_marker_mid:String = "";

    var m_marker_end:String = "";

    var m_font_family:String = "";

    /**
     * The initial state (`SVGLayoutState()`).
     */
    public function new() {}

    /**
     * `SVGLayoutState(parent, element)`: the state of `element`, child of
     * the element of `parent`.
     */
    public static function child(parent:SVGLayoutState, element:SVGElement):SVGLayoutState {
        var state = new SVGLayoutState();
        state.initFromParent(parent, element);
        return state;
    }

    function initFromParent(parent:SVGLayoutState, element:SVGElement):Void {
        m_parent = parent;
        m_element = element;
        m_fill = parent.fill();
        m_stroke = parent.stroke();
        m_color = parent.color();
        m_fill_opacity = parent.fillOpacity();
        m_stroke_opacity = parent.strokeOpacity();
        m_stroke_miterlimit = parent.strokeMiterlimit();
        m_font_size = parent.fontSize();
        m_letter_spacing = parent.letterSpacing();
        m_word_spacing = parent.wordSpacing();
        m_stroke_width = parent.strokeWidth();
        m_stroke_dashoffset = parent.strokeDashoffset();
        m_stroke_dasharray = parent.strokeDasharray();
        m_stroke_linecap = parent.strokeLinecap();
        m_stroke_linejoin = parent.strokeLinejoin();
        m_fill_rule = parent.fillRule();
        m_clip_rule = parent.clipRule();
        m_font_weight = parent.fontWeight();
        m_font_style = parent.fontStyle();
        m_dominant_baseline = parent.dominantBaseline();
        m_text_anchor = parent.textAnchor();
        m_white_space = parent.whiteSpace();
        m_writing_mode = parent.writingMode();
        m_text_orientation = parent.textOrientation();
        m_direction = parent.direction();
        m_visibility = parent.visibility();
        m_overflow = element.isRootElement() ? lunasvg.SVGProperty.Overflow.Visible : lunasvg.SVGProperty.Overflow.Hidden;
        m_pointer_events = parent.pointerEvents();
        m_marker_start = parent.markerStart();
        m_marker_mid = parent.markerMid();
        m_marker_end = parent.markerEnd();
        m_font_family = parent.fontFamily();

        for (attribute in element.attributes()) {
            var input = new StringView(attribute.value());
            stripLeadingAndTrailingSpaces(input);
            if (input.empty() || input.equals("inherit"))
                continue;
            switch (attribute.id()) {
                case PropertyID.Fill:
                    m_fill = parsePaint(input, this, lunasvg.Graphics.Color.Black);
                case PropertyID.Stroke:
                    m_stroke = parsePaint(input, this, lunasvg.Graphics.Color.Transparent);
                case PropertyID.Color:
                    m_color = parseColor(input, this, lunasvg.Graphics.Color.Black);
                case PropertyID.Stop_Color:
                    m_stop_color = parseColor(input, this, lunasvg.Graphics.Color.Black);
                case PropertyID.Opacity:
                    m_opacity = parseNumberOrPercentage(input, true, 1);
                case PropertyID.Fill_Opacity:
                    m_fill_opacity = parseNumberOrPercentage(input, true, 1);
                case PropertyID.Stroke_Opacity:
                    m_stroke_opacity = parseNumberOrPercentage(input, true, 1);
                case PropertyID.Stop_Opacity:
                    m_stop_opacity = parseNumberOrPercentage(input, true, 1);
                case PropertyID.Stroke_Miterlimit:
                    m_stroke_miterlimit = parseNumberOrPercentage(input, false, 4);
                case PropertyID.Font_Size:
                    m_font_size = parseFontSize(input, this);
                case PropertyID.Letter_Spacing:
                    m_letter_spacing = parseLengthOrNormal(input);
                case PropertyID.Word_Spacing:
                    m_word_spacing = parseLengthOrNormal(input);
                case PropertyID.Baseline_Shift:
                    m_baseline_shift = parseBaselineShift(input);
                case PropertyID.Stroke_Width:
                    m_stroke_width = parseLength(input, Forbid, new Length(1, None));
                case PropertyID.Stroke_Dashoffset:
                    m_stroke_dashoffset = parseLength(input, Allow, new Length(0, None));
                case PropertyID.Stroke_Dasharray:
                    m_stroke_dasharray = parseDashArray(input);
                case PropertyID.Stroke_Linecap:
                    m_stroke_linecap = parseLineCap(input);
                case PropertyID.Stroke_Linejoin:
                    m_stroke_linejoin = parseLineJoin(input);
                case PropertyID.Fill_Rule:
                    m_fill_rule = parseFillRule(input);
                case PropertyID.Clip_Rule:
                    m_clip_rule = parseFillRule(input);
                case PropertyID.Font_Weight:
                    m_font_weight = parseFontWeight(input);
                case PropertyID.Font_Style:
                    m_font_style = parseFontStyle(input);
                case PropertyID.Alignment_Baseline:
                    m_alignment_baseline = parseAlignmentBaseline(input);
                case PropertyID.Dominant_Baseline:
                    m_dominant_baseline = parseDominantBaseline(input);
                case PropertyID.Direction:
                    m_direction = parseDirection(input);
                case PropertyID.Text_Anchor:
                    m_text_anchor = parseTextAnchor(input);
                case PropertyID.White_Space:
                    m_white_space = parseWhiteSpace(input);
                case PropertyID.Writing_Mode:
                    m_writing_mode = parseWritingMode(input);
                case PropertyID.Text_Orientation:
                    m_text_orientation = parseTextOrientation(input);
                case PropertyID.Display:
                    m_display = parseDisplay(input);
                case PropertyID.Visibility:
                    m_visibility = parseVisibility(input);
                case PropertyID.Overflow:
                    m_overflow = parseOverflow(input);
                case PropertyID.Pointer_Events:
                    m_pointer_events = parsePointerEvents(input);
                case PropertyID.Mask_Type:
                    m_mask_type = parseMaskType(input);
                case PropertyID.Mask:
                    m_mask = parseUrl(input);
                case PropertyID.Clip_Path:
                    m_clip_path = parseUrl(input);
                case PropertyID.Marker_Start:
                    m_marker_start = parseUrl(input);
                case PropertyID.Marker_Mid:
                    m_marker_mid = parseUrl(input);
                case PropertyID.Marker_End:
                    m_marker_end = parseUrl(input);
                case PropertyID.Font_Family:
                    m_font_family = input.toString();
                default:
            }
        }
    }

    public inline function parent():Null<SVGLayoutState> return m_parent;
    public inline function element():Null<SVGElement> return m_element;

    public inline function fill():lunasvg.SVGProperty.Paint return m_fill;
    public inline function stroke():lunasvg.SVGProperty.Paint return m_stroke;

    public inline function color():lunasvg.Graphics.Color return m_color;
    public inline function stopColor():lunasvg.Graphics.Color return m_stop_color;

    public inline function opacity():Float return m_opacity;
    public inline function stopOpacity():Float return m_stop_opacity;
    public inline function fillOpacity():Float return m_fill_opacity;
    public inline function strokeOpacity():Float return m_stroke_opacity;
    public inline function strokeMiterlimit():Float return m_stroke_miterlimit;
    public inline function fontSize():Float return m_font_size;

    public inline function letterSpacing():Length return m_letter_spacing;
    public inline function wordSpacing():Length return m_word_spacing;

    public inline function baselineShift():BaselineShift return m_baseline_shift;
    public inline function strokeWidth():Length return m_stroke_width;
    public inline function strokeDashoffset():Length return m_stroke_dashoffset;
    public inline function strokeDasharray():LengthList return m_stroke_dasharray;

    public inline function strokeLinecap():LineCap return m_stroke_linecap;
    public inline function strokeLinejoin():LineJoin return m_stroke_linejoin;

    public inline function fillRule():FillRule return m_fill_rule;
    public inline function clipRule():FillRule return m_clip_rule;

    public inline function fontWeight():FontWeight return m_font_weight;
    public inline function fontStyle():FontStyle return m_font_style;

    public inline function alignmentBaseline():AlignmentBaseline return m_alignment_baseline;
    public inline function dominantBaseline():DominantBaseline return m_dominant_baseline;

    public inline function textAnchor():TextAnchor return m_text_anchor;
    public inline function whiteSpace():WhiteSpace return m_white_space;
    public inline function writingMode():WritingMode return m_writing_mode;
    public inline function textOrientation():TextOrientation return m_text_orientation;
    public inline function direction():Direction return m_direction;

    public inline function display():Display return m_display;
    public inline function visibility():Visibility return m_visibility;
    public inline function overflow():Overflow return m_overflow;
    public inline function pointerEvents():PointerEvents return m_pointer_events;
    public inline function maskType():MaskType return m_mask_type;

    public inline function mask():String return m_mask;
    public inline function clipPath():String return m_clip_path;
    public inline function markerStart():String return m_marker_start;
    public inline function markerMid():String return m_marker_mid;
    public inline function markerEnd():String return m_marker_end;
    public inline function fontFamily():String return m_font_family;

    public function font():Font {
        var bold = m_font_weight == FontWeight.Bold;
        var italic = m_font_style == FontStyle.Italic;

        var face:Null<lunasvg.FontProvider.FontFace> = null;
        var input = new StringView(m_font_family);
        while (!input.empty() && face == null) {
            var comma = input.findChar(','.code);
            var family = input.substr(0, comma);
            input.removePrefix(family.length());
            if (!input.empty() && input.front() == ','.code)
                input.removePrefix(1);
            stripLeadingAndTrailingSpaces(family);
            if (!family.empty() && (family.front() == '\''.code || family.front() == '"'.code)) {
                var quote = family.front();
                family.removePrefix(1);
                if (!family.empty() && family.back() == quote)
                    family.removeSuffix(1);
                stripLeadingAndTrailingSpaces(family);
            }

            var fontFamily = family.toString();
            if (fontFamily.length > 0) {
                face = FontFaceCache.fontFaceCache().getFontFace(fontFamily, bold, italic);
            }
        }

        if (face == null)
            face = FontFaceCache.fontFaceCache().getFontFace("", bold, italic);
        return new Font(face, m_font_size);
    }

    // Value parsers (static functions of svglayoutstate.cpp)

    static var colorParser:plutovg.Color = new plutovg.Color();

    /**
     * Returns the parsed color, or -1 in `parsedOk` terms: `colorValid` is
     * set to false when the input is not a color.
     */
    static var colorValid:Bool = false;

    static function parseColorValue(input:StringView, state:SVGLayoutState):lunasvg.Graphics.Color {
        if (skipString(input, "currentColor")) {
            colorValid = true;
            return state.color();
        }

        var length = colorParser.parse(input.toString());
        if (length == 0) {
            colorValid = false;
            return lunasvg.Graphics.Color.Transparent;
        }
        input.removePrefix(length);
        colorValid = true;
        return new lunasvg.Graphics.Color(colorParser.toArgb32());
    }

    static function parseColor(input:StringView, state:SVGLayoutState, defaultValue:lunasvg.Graphics.Color):lunasvg.Graphics.Color {
        var color = parseColorValue(input, state);
        if (!colorValid || !input.empty())
            color = defaultValue;
        return color;
    }

    static function parseColorOrNone(input:StringView, state:SVGLayoutState, defaultValue:lunasvg.Graphics.Color):lunasvg.Graphics.Color {
        if (input.equals("none"))
            return lunasvg.Graphics.Color.Transparent;
        return parseColor(input, state, defaultValue);
    }

    /**
     * `parseUrlValue()`: returns the id, or null on failure.
     */
    static function parseUrlValue(input:StringView):Null<String> {
        if (!skipString(input, "url")
            || !skipOptionalSpaces(input)
            || !skipDelimiter(input, '('.code)
            || !skipOptionalSpaces(input)) {
            return null;
        }

        var value = new StringBuf();
        switch (input.front()) {
            case '\''.code | '"'.code:
                var delim = input.front();
                input.removePrefix(1);
                skipOptionalSpaces(input);
                if (!skipDelimiter(input, '#'.code))
                    return null;
                while (!input.empty() && input.front() != delim) {
                    value.addChar(input.front());
                    input.removePrefix(1);
                }

                skipOptionalSpaces(input);
                if (!skipDelimiter(input, delim))
                    return null;
            case '#'.code:
                input.removePrefix(1);
                while (!input.empty() && input.front() != ')'.code) {
                    value.addChar(input.front());
                    input.removePrefix(1);
                }
            default:
                return null;
        }

        if (skipOptionalSpaces(input) && skipDelimiter(input, ')'.code))
            return value.toString();
        return null;
    }

    static function parseUrl(input:StringView):String {
        var value = parseUrlValue(input);
        if (value == null || !input.empty())
            return "";
        return value;
    }

    static function parsePaint(input:StringView, state:SVGLayoutState, defaultValue:lunasvg.Graphics.Color):lunasvg.SVGProperty.Paint {
        var id = parseUrlValue(input);
        if (id == null)
            return lunasvg.SVGProperty.Paint.ofColor(parseColorOrNone(input, state, defaultValue));
        if (skipOptionalSpaces(input))
            return new lunasvg.SVGProperty.Paint(id, parseColorOrNone(input, state, defaultValue));
        return new lunasvg.SVGProperty.Paint(id, lunasvg.Graphics.Color.Transparent);
    }

    static function parseNumberOrPercentage(input:StringView, allowPercentage:Bool, defaultValue:Float):Float {
        var value = parseNumber(input);
        if (Math.isNaN(value))
            return defaultValue;
        if (allowPercentage) {
            if (skipDelimiter(input, '%'.code))
                value = f32(value / 100);
            value = value < 0 ? 0 : (value > 1 ? 1 : value);
        }

        if (!input.empty())
            return defaultValue;
        return value;
    }

    static function parseLength(input:StringView, mode:LengthNegativeMode, defaultValue:Length):Length {
        var value = new Length();
        if (!value.parse(input, mode))
            value = defaultValue.clone();
        return value;
    }

    static function parseBaselineShift(input:StringView):BaselineShift {
        if (input.equals("baseline"))
            return new BaselineShift(Baseline);
        if (input.equals("sub"))
            return new BaselineShift(Sub);
        if (input.equals("super"))
            return new BaselineShift(Super);
        return BaselineShift.ofLength(parseLength(input, Allow, new Length(0, None)));
    }

    static function parseDashArray(input:StringView):LengthList {
        if (input.equals("none"))
            return [];
        var values:LengthList = [];
        do {
            var count = 0;
            while (count < input.length() && input.at(count) != ','.code && !IS_WS(input.at(count)))
                ++count;
            var value = new Length(0, None);
            if (!value.parse(input.substr(0, count), Forbid))
                return [];
            input.removePrefix(count);
            values.push(value);
        } while (skipOptionalSpacesOrComma(input));
        return values;
    }

    static function parseLengthOrNormal(input:StringView):Length {
        if (input.equals("normal"))
            return new Length(0, None);
        return parseLength(input, Allow, new Length(0, None));
    }

    static function parseFontSize(input:StringView, state:SVGLayoutState):Float {
        var length = parseLength(input, Forbid, new Length(12, None));
        if (length.units() == Percent)
            return f32(f32(length.value() * state.fontSize()) / 100);
        if (length.units() == Ex)
            return f32(f32(length.value() * state.fontSize()) / 2);
        if (length.units() == Em)
            return f32(length.value() * state.fontSize());
        return length.value();
    }

    static function parseEnumValue(input:StringView, names:Array<String>, values:Array<Int>, defaultValue:Int):Int {
        for (i in 0...names.length) {
            if (input.equals(names[i])) {
                return values[i];
            }
        }

        return defaultValue;
    }

    static function parseDisplay(input:StringView):Display {
        return parseEnumValue(input, ["inline", "none"], [Display.Inline, Display.None], Display.Inline);
    }

    static function parseVisibility(input:StringView):Visibility {
        return parseEnumValue(input, ["visible", "hidden", "collapse"], [Visibility.Visible, Visibility.Hidden, Visibility.Collapse], Visibility.Visible);
    }

    static function parseOverflow(input:StringView):Overflow {
        return parseEnumValue(input, ["visible", "hidden"], [Overflow.Visible, Overflow.Hidden], Overflow.Visible);
    }

    static function parsePointerEvents(input:StringView):PointerEvents {
        return parseEnumValue(input, [
            "none", "auto", "stroke", "fill", "painted", "visible", "visibleStroke", "visibleFill", "visiblePainted", "bounding-box", "all"
        ], [
            PointerEvents.None, PointerEvents.Auto, PointerEvents.Stroke, PointerEvents.Fill, PointerEvents.Painted, PointerEvents.Visible,
            PointerEvents.VisibleStroke, PointerEvents.VisibleFill, PointerEvents.VisiblePainted, PointerEvents.BoundingBox, PointerEvents.All
        ], PointerEvents.Auto);
    }

    static function parseFontWeight(input:StringView):FontWeight {
        return parseEnumValue(input, [
            "normal", "bold", "bolder", "lighter", "100", "200", "300", "400", "500", "600", "700", "800", "900"
        ], [
            FontWeight.Normal, FontWeight.Bold, FontWeight.Bold, FontWeight.Normal, FontWeight.Normal, FontWeight.Normal, FontWeight.Normal,
            FontWeight.Normal, FontWeight.Normal, FontWeight.Bold, FontWeight.Bold, FontWeight.Bold, FontWeight.Bold
        ], FontWeight.Normal);
    }

    static function parseFontStyle(input:StringView):FontStyle {
        return parseEnumValue(input, ["normal", "italic", "oblique"], [FontStyle.Normal, FontStyle.Italic, FontStyle.Italic], FontStyle.Normal);
    }

    static function parseAlignmentBaseline(input:StringView):AlignmentBaseline {
        return parseEnumValue(input, [
            "auto", "baseline", "before-edge", "text-before-edge", "middle", "central", "after-edge", "text-after-edge", "ideographic",
            "alphabetic", "hanging", "mathematical"
        ], [
            AlignmentBaseline.Auto, AlignmentBaseline.Baseline, AlignmentBaseline.BeforeEdge, AlignmentBaseline.TextBeforeEdge,
            AlignmentBaseline.Middle, AlignmentBaseline.Central, AlignmentBaseline.AfterEdge, AlignmentBaseline.TextAfterEdge,
            AlignmentBaseline.Ideographic, AlignmentBaseline.Alphabetic, AlignmentBaseline.Hanging, AlignmentBaseline.Mathematical
        ], AlignmentBaseline.Auto);
    }

    static function parseDominantBaseline(input:StringView):DominantBaseline {
        return parseEnumValue(input, [
            "auto", "use-script", "no-change", "reset-size", "ideographic", "alphabetic", "hanging", "mathematical", "central", "middle",
            "text-after-edge", "text-before-edge"
        ], [
            DominantBaseline.Auto, DominantBaseline.UseScript, DominantBaseline.NoChange, DominantBaseline.ResetSize,
            DominantBaseline.Ideographic, DominantBaseline.Alphabetic, DominantBaseline.Hanging, DominantBaseline.Mathematical,
            DominantBaseline.Central, DominantBaseline.Middle, DominantBaseline.TextAfterEdge, DominantBaseline.TextBeforeEdge
        ], DominantBaseline.Auto);
    }

    static function parseDirection(input:StringView):Direction {
        return parseEnumValue(input, ["ltr", "rtl"], [Direction.Ltr, Direction.Rtl], Direction.Ltr);
    }

    static function parseWritingMode(input:StringView):WritingMode {
        return parseEnumValue(input, ["horizontal-tb", "vertical-rl", "vertical-lr", "lr-tb", "lr", "rl-tb", "rl", "tb-rl", "tb"], [
            WritingMode.Horizontal, WritingMode.Vertical, WritingMode.Vertical, WritingMode.Horizontal, WritingMode.Horizontal,
            WritingMode.Horizontal, WritingMode.Horizontal, WritingMode.Vertical, WritingMode.Vertical
        ], WritingMode.Horizontal);
    }

    static function parseTextOrientation(input:StringView):TextOrientation {
        return parseEnumValue(input, ["mixed", "upright"], [TextOrientation.Mixed, TextOrientation.Upright], TextOrientation.Mixed);
    }

    static function parseTextAnchor(input:StringView):TextAnchor {
        return parseEnumValue(input, ["start", "middle", "end"], [TextAnchor.Start, TextAnchor.Middle, TextAnchor.End], TextAnchor.Start);
    }

    static function parseWhiteSpace(input:StringView):WhiteSpace {
        return parseEnumValue(input, ["default", "preserve", "normal", "nowrap", "pre-line", "pre-wrap", "pre"], [
            WhiteSpace.Default, WhiteSpace.Preserve, WhiteSpace.Default, WhiteSpace.Default, WhiteSpace.Default, WhiteSpace.Preserve,
            WhiteSpace.Preserve
        ], WhiteSpace.Default);
    }

    static function parseMaskType(input:StringView):MaskType {
        return parseEnumValue(input, ["luminance", "alpha"], [MaskType.Luminance, MaskType.Alpha], MaskType.Luminance);
    }

    static function parseFillRule(input:StringView):FillRule {
        return parseEnumValue(input, ["nonzero", "evenodd"], [(FillRule.NonZero : Int), (FillRule.EvenOdd : Int)], (FillRule.NonZero : Int));
    }

    static function parseLineCap(input:StringView):LineCap {
        return parseEnumValue(input, ["butt", "round", "square"], [(LineCap.Butt : Int), (LineCap.Round : Int), (LineCap.Square : Int)], (LineCap.Butt : Int));
    }

    static function parseLineJoin(input:StringView):LineJoin {
        return parseEnumValue(input, ["miter", "round", "bevel"], [(LineJoin.Miter : Int), (LineJoin.Round : Int), (LineJoin.Bevel : Int)],
            (LineJoin.Miter : Int));
    }

}
