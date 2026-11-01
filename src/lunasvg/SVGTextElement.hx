// Ported from lunasvg 3.5.0: source/svgtextelement.h, source/svgtextelement.cpp
// Original code Copyright (c) 2020-2026 Samuel Ugochukwu, licensed under MIT.
// Modified: translated from C++ to Haxe. See LICENSE.
package lunasvg;

import lunasvg.Graphics;
import lunasvg.SVGElement;
import lunasvg.SVGLayoutState;
import lunasvg.SVGProperty;
import lunasvg.SVGRenderState;
import plutovg.Utils.f32;

/**
 * Explicit positions of a character (`SVGCharacterPosition`): NaN means
 * "not set" (`std::nullopt`).
 */
class SVGCharacterPosition {

    public var x:Float = Math.NaN;

    public var y:Float = Math.NaN;

    public var dx:Float = Math.NaN;

    public var dy:Float = Math.NaN;

    public var rotate:Float = Math.NaN;

    public function new() {}

}

class SVGTextPosition {

    public var node:SVGNode;

    public var startOffset:Int;

    public var endOffset:Int;

    public function new(node:SVGNode, startOffset:Int, endOffset:Int) {
        this.node = node;
        this.startOffset = startOffset;
        this.endOffset = endOffset;
    }

}

typedef SVGTextPositionList = Array<SVGTextPosition>;

class SVGTextFragment {

    public var element:SVGTextPositioningElement;

    public var lengthAdjustTransform:Transform = new Transform();

    public var offset:Int = 0;

    public var length:Int = 0;

    public var startsNewTextChunk:Bool = false;

    public var x:Float = 0;

    public var y:Float = 0;

    public var width:Float = 0;

    public var height:Float = 0;

    public var angle:Float = 0;

    public function new(element:SVGTextPositioningElement) {
        this.element = element;
    }

    public function clone():SVGTextFragment {
        var f = new SVGTextFragment(element);
        f.lengthAdjustTransform = lengthAdjustTransform.clone();
        f.offset = offset;
        f.length = length;
        f.startsNewTextChunk = startsNewTextChunk;
        f.x = x;
        f.y = y;
        f.width = width;
        f.height = height;
        f.angle = angle;
        return f;
    }

}

typedef SVGTextFragmentList = Array<SVGTextFragment>;

class SVGTextFragmentsBuilder {

    var m_text:Array<Int>;

    var m_fragments:SVGTextFragmentList;

    var m_characterPositions:Map<Int, SVGCharacterPosition> = new Map();

    var m_textPositions:SVGTextPositionList = [];

    var m_characterOffset:Int = 0;

    var m_x:Float = 0;

    var m_y:Float = 0;

    public function new(text:Array<Int>, fragments:SVGTextFragmentList) {
        m_text = text;
        m_fragments = fragments;
        m_text.resize(0);
        m_fragments.resize(0);
    }

    static function resolveDominantBaseline(element:SVGTextPositioningElement):AlignmentBaseline {
        switch (element.dominantBaseline()) {
            case DominantBaseline.Auto:
                if (element.isVerticalWritingMode())
                    return AlignmentBaseline.Central;
                return AlignmentBaseline.Alphabetic;
            case DominantBaseline.UseScript | DominantBaseline.NoChange | DominantBaseline.ResetSize:
                return AlignmentBaseline.Auto;
            case DominantBaseline.Ideographic:
                return AlignmentBaseline.Ideographic;
            case DominantBaseline.Alphabetic:
                return AlignmentBaseline.Alphabetic;
            case DominantBaseline.Hanging:
                return AlignmentBaseline.Hanging;
            case DominantBaseline.Mathematical:
                return AlignmentBaseline.Mathematical;
            case DominantBaseline.Central:
                return AlignmentBaseline.Central;
            case DominantBaseline.Middle:
                return AlignmentBaseline.Middle;
            case DominantBaseline.TextAfterEdge:
                return AlignmentBaseline.TextAfterEdge;
            case DominantBaseline.TextBeforeEdge:
                return AlignmentBaseline.TextBeforeEdge;
            default:
        }

        return AlignmentBaseline.Auto;
    }

    static function calculateBaselineOffset(element:SVGTextPositioningElement):Float {
        var offset = element.baselineOffset();
        var parent = element.parentElement();
        while (parent.isTextPositioningElement()) {
            offset = f32(offset + (cast parent : SVGTextPositioningElement).baselineOffset());
            parent = parent.parentElement();
        }

        var baseline = element.alignmentBaseline();
        if (baseline == AlignmentBaseline.Auto || baseline == AlignmentBaseline.Baseline) {
            baseline = resolveDominantBaseline(element);
        }

        var font = element.font();
        switch (baseline) {
            case AlignmentBaseline.BeforeEdge | AlignmentBaseline.TextBeforeEdge:
                offset = f32(offset - font.ascent());
            case AlignmentBaseline.Middle:
                offset = f32(offset - f32(font.xHeight() / 2));
            case AlignmentBaseline.Central:
                offset = f32(offset - f32(f32(font.ascent() + font.descent()) / 2));
            case AlignmentBaseline.AfterEdge | AlignmentBaseline.TextAfterEdge | AlignmentBaseline.Ideographic:
                offset = f32(offset - font.descent());
            case AlignmentBaseline.Hanging:
                offset = f32(offset - f32(f32(font.ascent() * 8) / 10));
            case AlignmentBaseline.Mathematical:
                offset = f32(offset - f32(font.ascent() / 2));
            default:
        }

        return offset;
    }

    static function needsTextAnchorAdjustment(element:SVGTextPositioningElement):Bool {
        var direction = element.direction();
        switch (element.textAnchor()) {
            case TextAnchor.Start:
                return direction == Direction.Rtl;
            case TextAnchor.Middle:
                return true;
            case TextAnchor.End:
                return direction == Direction.Ltr;
            default:
        }

        return false;
    }

    static function calculateTextAnchorOffset(element:SVGTextPositioningElement, width:Float):Float {
        var direction = element.direction();
        switch (element.textAnchor()) {
            case TextAnchor.Start:
                if (direction == Direction.Ltr)
                    return 0;
                return -width;
            case TextAnchor.Middle:
                return f32(-width / 2);
            case TextAnchor.End:
                if (direction == Direction.Ltr)
                    return -width;
                return 0;
            default:
        }

        return 0;
    }

    static function calculateTextChunkLength(fragments:SVGTextFragmentList, begin:Int, end:Int, isVerticalText:Bool):Float {
        var chunkLength = 0.0;
        var lastFragment:Null<SVGTextFragment> = null;
        for (i in begin...end) {
            var fragment = fragments[i];
            chunkLength = f32(chunkLength + (isVerticalText ? fragment.height : fragment.width));
            if (lastFragment == null) {
                lastFragment = fragment;
                continue;
            }

            if (isVerticalText) {
                chunkLength = f32(chunkLength + f32(fragment.y - f32(lastFragment.y + lastFragment.height)));
            } else {
                chunkLength = f32(chunkLength + f32(fragment.x - f32(lastFragment.x + lastFragment.width)));
            }

            lastFragment = fragment;
        }

        return chunkLength;
    }

    static function handleTextChunk(fragments:SVGTextFragmentList, begin:Int, end:Int):Void {
        var firstFragment = fragments[begin];
        var isVerticalText = firstFragment.element.isVerticalWritingMode();
        if (firstFragment.element.hasAttribute(PropertyID.TextLength)) {
            var lengthContext = new LengthContext(firstFragment.element);
            var textLength = lengthContext.valueForSVGLength(firstFragment.element.textLength());
            var chunkLength = calculateTextChunkLength(fragments, begin, end, isVerticalText);
            if (textLength > 0 && chunkLength > 0) {
                var numCharacters = 0;
                for (i in begin...end) {
                    numCharacters += fragments[i].length;
                }

                if (firstFragment.element.lengthAdjust() == LengthAdjust.SpacingAndGlyphs) {
                    var textLengthScale = f32(textLength / chunkLength);
                    var lengthAdjustTransform = Transform.translated(firstFragment.x, firstFragment.y);
                    if (isVerticalText) {
                        lengthAdjustTransform.scale(1, textLengthScale);
                    } else {
                        lengthAdjustTransform.scale(textLengthScale, 1);
                    }

                    lengthAdjustTransform.translate(-firstFragment.x, -firstFragment.y);
                    for (i in begin...end) {
                        fragments[i].lengthAdjustTransform = lengthAdjustTransform.clone();
                    }
                } else if (numCharacters > 1) {
                    var characterOffset = 0;
                    var textLengthShift = f32(f32(textLength - chunkLength) / (numCharacters - 1));
                    for (i in begin...end) {
                        var fragment = fragments[i];
                        if (isVerticalText) {
                            fragment.y = f32(fragment.y + f32(textLengthShift * characterOffset));
                        } else {
                            fragment.x = f32(fragment.x + f32(textLengthShift * characterOffset));
                        }

                        characterOffset += fragment.length;
                    }
                }
            }
        }

        if (needsTextAnchorAdjustment(firstFragment.element)) {
            var chunkLength = calculateTextChunkLength(fragments, begin, end, isVerticalText);
            var chunkOffset = calculateTextAnchorOffset(firstFragment.element, chunkLength);
            for (i in begin...end) {
                var fragment = fragments[i];
                if (isVerticalText) {
                    fragment.y = f32(fragment.y + chunkOffset);
                } else {
                    fragment.x = f32(fragment.x + chunkOffset);
                }
            }
        }
    }

    public function build(textElement:SVGTextElement):Void {
        handleElement(textElement);
        for (position in m_textPositions) {
            fillCharacterPositions(position);
        }

        var wholeText = m_text;
        for (textPosition in m_textPositions) {
            if (!textPosition.node.isTextNode())
                continue;
            var element:SVGTextPositioningElement = cast textPosition.node.parentElement();
            var isVerticalText = element.isVerticalWritingMode();
            var isUprightText = element.isUprightTextOrientation();
            var font = element.font();

            var fragment = new SVGTextFragment(element);
            inline function recordTextFragment(startOffset:Int, endOffset:Int):Void {
                fragment.offset = startOffset;
                fragment.length = endOffset - startOffset;
                fragment.width = font.measureText(wholeText, startOffset, endOffset - startOffset);
                fragment.height = f32(font.height() + font.lineGap());
                if (isVerticalText) {
                    m_y = f32(m_y + (isUprightText ? fragment.height : fragment.width));
                } else {
                    m_x = f32(m_x + fragment.width);
                }

                m_fragments.push(fragment.clone());
            }

            var needsTextLengthSpacing = element.lengthAdjust() == LengthAdjust.Spacing && element.hasAttribute(PropertyID.TextLength);
            var baselineOffset = calculateBaselineOffset(element);
            var startOffset = textPosition.startOffset;
            var textOffset = textPosition.startOffset;
            var didStartTextFragment = false;
            var applySpacingToNextCharacter = false;
            var lastCharacter = 0;
            var lastAngle = 0.0;
            while (textOffset < textPosition.endOffset) {
                var characterPosition = m_characterPositions.get(m_characterOffset);
                if (characterPosition == null)
                    characterPosition = EMPTY_POSITION;

                var currentCharacter = wholeText[textOffset];
                var angle = Math.isNaN(characterPosition.rotate) ? 0 : characterPosition.rotate;
                var dx = Math.isNaN(characterPosition.dx) ? 0 : characterPosition.dx;
                var dy = Math.isNaN(characterPosition.dy) ? 0 : characterPosition.dy;
                var hasX = !Math.isNaN(characterPosition.x);
                var hasY = !Math.isNaN(characterPosition.y);

                var shouldStartNewFragment = needsTextLengthSpacing || isVerticalText || applySpacingToNextCharacter
                    || hasX || hasY || dx != 0 || dy != 0 || angle != 0 || angle != lastAngle;
                if (shouldStartNewFragment && didStartTextFragment) {
                    recordTextFragment(startOffset, textOffset);
                    applySpacingToNextCharacter = false;
                    startOffset = textOffset;
                }

                var startsNewTextChunk = (hasX || hasY) && textOffset == textPosition.startOffset;
                if (startsNewTextChunk || shouldStartNewFragment || !didStartTextFragment) {
                    m_x = f32(dx + (hasX ? characterPosition.x : m_x));
                    m_y = f32(dy + (hasY ? characterPosition.y : m_y));
                    fragment.x = isVerticalText ? f32(m_x + baselineOffset) : m_x;
                    fragment.y = isVerticalText ? m_y : f32(m_y - baselineOffset);
                    fragment.angle = angle;
                    if (isVerticalText) {
                        if (isUprightText) {
                            fragment.y = f32(fragment.y + font.height());
                        } else {
                            fragment.angle = f32(fragment.angle + 90);
                        }
                    }

                    fragment.startsNewTextChunk = startsNewTextChunk;
                    didStartTextFragment = true;
                }

                var spacing = element.letterSpacing();
                if (currentCharacter != 0 && lastCharacter != 0 && element.wordSpacing() != 0) {
                    if (currentCharacter == ' '.code && lastCharacter != ' '.code) {
                        spacing = f32(spacing + element.wordSpacing());
                    }
                }

                if (spacing != 0) {
                    applySpacingToNextCharacter = true;
                    if (isVerticalText) {
                        m_y = f32(m_y + spacing);
                    } else {
                        m_x = f32(m_x + spacing);
                    }
                }

                lastAngle = angle;
                lastCharacter = currentCharacter;
                ++textOffset;
                ++m_characterOffset;
            }

            recordTextFragment(startOffset, textOffset);
        }

        if (m_fragments.length == 0)
            return;
        var begin = 0;
        var it = 1;
        while (it < m_fragments.length) {
            var fragment = m_fragments[it];
            if (fragment.startsNewTextChunk) {
                handleTextChunk(m_fragments, begin, it);
                begin = it;
            }
            it++;
        }

        handleTextChunk(m_fragments, begin, it);
    }

    static final EMPTY_POSITION = new SVGCharacterPosition();

    function handleText(node:SVGTextNode):Void {
        var text = node.data();
        if (text.length == 0)
            return;
        var element:SVGTextPositioningElement = cast node.parentElement();
        var startOffset = m_text.length;
        var lastCharacter = ' '.code;
        if (m_text.length > 0) {
            lastCharacter = m_text[m_text.length - 1];
        }

        for (codepoint in new haxe.iterators.StringIteratorUnicode(text)) {
            var currentCharacter = codepoint;
            if (currentCharacter == '\t'.code || currentCharacter == '\n'.code || currentCharacter == '\r'.code)
                currentCharacter = ' '.code;
            if (currentCharacter == ' '.code && lastCharacter == ' '.code && element.whiteSpace() == WhiteSpace.Default)
                continue;
            m_text.push(currentCharacter);
            lastCharacter = currentCharacter;
        }

        if (startOffset < m_text.length) {
            m_textPositions.push(new SVGTextPosition(node, startOffset, m_text.length));
        }
    }

    function handleElement(element:SVGTextPositioningElement):Void {
        if (element.isDisplayNone())
            return;
        var itemIndex = m_textPositions.length;
        m_textPositions.push(new SVGTextPosition(element, m_text.length, m_text.length));
        for (child in element.children()) {
            if (child.isTextNode()) {
                handleText(cast child);
            } else if (child.isTextPositioningElement()) {
                handleElement(cast child);
            }
        }

        var position = m_textPositions[itemIndex];
        position.endOffset = m_text.length;
    }

    function characterPositionAt(offset:Int):SVGCharacterPosition {
        var position = m_characterPositions.get(offset);
        if (position == null) {
            position = new SVGCharacterPosition();
            m_characterPositions.set(offset, position);
        }
        return position;
    }

    function fillCharacterPositions(position:SVGTextPosition):Void {
        if (!position.node.isTextPositioningElement())
            return;
        var element:SVGTextPositioningElement = cast position.node;
        var xList = element.x();
        var yList = element.y();
        var dxList = element.dx();
        var dyList = element.dy();
        var rotateList = element.rotate();

        var xListSize = xList.length;
        var yListSize = yList.length;
        var dxListSize = dxList.length;
        var dyListSize = dyList.length;
        var rotateListSize = rotateList.length;
        if (xListSize == 0 && yListSize == 0 && dxListSize == 0 && dyListSize == 0 && rotateListSize == 0) {
            return;
        }

        var lengthContext = new LengthContext(element);
        var lastRotation = Math.NaN;
        for (offset in position.startOffset...position.endOffset) {
            var index = offset - position.startOffset;
            if (index >= xListSize && index >= yListSize && index >= dxListSize && index >= dyListSize && index >= rotateListSize)
                break;
            var characterPosition = characterPositionAt(offset);
            if (index < xListSize)
                characterPosition.x = lengthContext.valueForLength(xList[index], Horizontal);
            if (index < yListSize)
                characterPosition.y = lengthContext.valueForLength(yList[index], Vertical);
            if (index < dxListSize)
                characterPosition.dx = lengthContext.valueForLength(dxList[index], Horizontal);
            if (index < dyListSize)
                characterPosition.dy = lengthContext.valueForLength(dyList[index], Vertical);
            if (index < rotateListSize) {
                characterPosition.rotate = rotateList[index];
                lastRotation = characterPosition.rotate;
            }
        }

        if (Math.isNaN(lastRotation))
            return;
        var offset = position.startOffset + rotateList.length;
        while (offset < position.endOffset) {
            characterPositionAt(offset++).rotate = lastRotation;
        }
    }

}

class SVGTextContentElement extends SVGGraphicsElement {

    var m_textLength:SVGLength;

    var m_lengthAdjust:SVGEnumeration;

    var m_font:Font = new Font();

    var m_fill:SVGPaintServer = new SVGPaintServer();

    var m_stroke:SVGPaintServer = new SVGPaintServer();

    var m_stroke_width:Float = 1;

    var m_letter_spacing:Float = 0;

    var m_word_spacing:Float = 0;

    var m_baseline_offset:Float = 0;

    var m_alignment_baseline:AlignmentBaseline = Auto;

    var m_dominant_baseline:DominantBaseline = Auto;

    var m_text_anchor:TextAnchor = Start;

    var m_white_space:WhiteSpace = Default;

    var m_writing_mode:WritingMode = Horizontal;

    var m_text_orientation:TextOrientation = Mixed;

    var m_direction:Direction = Ltr;

    public function new(document:Document, id:ElementID) {
        super(document, id);
        m_textLength = new SVGLength(PropertyID.TextLength, Horizontal, Forbid);
        m_lengthAdjust = new SVGEnumeration(PropertyID.LengthAdjust, (LengthAdjust.Spacing : Int), SVGEnumeration.LENGTH_ADJUST_ENTRIES);
        addProperty(m_textLength);
        addProperty(m_lengthAdjust);
    }

    override public function isTextContentElement():Bool {
        return true;
    }

    public inline function textLength():SVGLength return m_textLength;
    public inline function lengthAdjust():LengthAdjust return m_lengthAdjust.value();

    public inline function font():Font return m_font;
    public inline function fill():SVGPaintServer return m_fill;
    public inline function stroke():SVGPaintServer return m_stroke;

    public inline function isVerticalWritingMode():Bool return m_writing_mode == WritingMode.Vertical;
    public inline function isUprightTextOrientation():Bool return m_text_orientation == TextOrientation.Upright;

    public inline function strokeWidth():Float return m_stroke_width;
    public inline function letterSpacing():Float return m_letter_spacing;
    public inline function wordSpacing():Float return m_word_spacing;
    public inline function baselineOffset():Float return m_baseline_offset;
    public inline function alignmentBaseline():AlignmentBaseline return m_alignment_baseline;
    public inline function dominantBaseline():DominantBaseline return m_dominant_baseline;
    public inline function textAnchor():TextAnchor return m_text_anchor;
    public inline function whiteSpace():WhiteSpace return m_white_space;
    public inline function direction():Direction return m_direction;

    override public function layoutElement(state:SVGLayoutState):Void {
        m_font = state.font();
        m_fill = getPaintServer(state.fill(), state.fillOpacity());
        m_stroke = getPaintServer(state.stroke(), state.strokeOpacity());
        super.layoutElement(state);

        var lengthContext = new LengthContext(this);
        m_stroke_width = lengthContext.valueForLength(state.strokeWidth(), Diagonal);
        m_letter_spacing = lengthContext.valueForLength(state.letterSpacing(), Diagonal);
        m_word_spacing = lengthContext.valueForLength(state.wordSpacing(), Diagonal);

        m_baseline_offset = convertBaselineOffset(state.baselineShift());
        m_alignment_baseline = state.alignmentBaseline();
        m_dominant_baseline = state.dominantBaseline();
        m_text_anchor = state.textAnchor();
        m_white_space = state.whiteSpace();
        m_writing_mode = state.writingMode();
        m_text_orientation = state.textOrientation();
        m_direction = state.direction();
    }

    function convertBaselineOffset(baselineShift:BaselineShift):Float {
        if (baselineShift.type() == BaselineShiftType.Baseline)
            return 0;
        if (baselineShift.type() == BaselineShiftType.Sub)
            return f32(-m_font.height() / 2);
        if (baselineShift.type() == BaselineShiftType.Super) {
            return f32(m_font.height() / 2);
        }

        var length = baselineShift.length();
        if (length.units() == Percent)
            return f32(f32(length.value() * m_font.size()) / 100);
        if (length.units() == Ex)
            return f32(f32(length.value() * m_font.size()) / 2);
        if (length.units() == Em)
            return f32(length.value() * m_font.size());
        return length.value();
    }

}

class SVGTextPositioningElement extends SVGTextContentElement {

    var m_x:SVGLengthList;

    var m_y:SVGLengthList;

    var m_dx:SVGLengthList;

    var m_dy:SVGLengthList;

    var m_rotate:SVGNumberList;

    public function new(document:Document, id:ElementID) {
        super(document, id);
        m_x = new SVGLengthList(PropertyID.X, Horizontal, Allow);
        m_y = new SVGLengthList(PropertyID.Y, Vertical, Allow);
        m_dx = new SVGLengthList(PropertyID.Dx, Horizontal, Allow);
        m_dy = new SVGLengthList(PropertyID.Dy, Vertical, Allow);
        m_rotate = new SVGNumberList(PropertyID.Rotate);
        addProperty(m_x);
        addProperty(m_y);
        addProperty(m_dx);
        addProperty(m_dy);
        addProperty(m_rotate);
    }

    override public function isTextPositioningElement():Bool {
        return true;
    }

    public inline function x():LengthList return m_x.values();
    public inline function y():LengthList return m_y.values();
    public inline function dx():LengthList return m_dx.values();
    public inline function dy():LengthList return m_dy.values();
    public inline function rotate():NumberList return m_rotate.values();

}

class SVGTSpanElement extends SVGTextPositioningElement {

    public function new(document:Document) {
        super(document, ElementID.Tspan);
    }

}

class SVGTextElement extends SVGTextPositioningElement {

    var m_fragments:SVGTextFragmentList = [];

    var m_text:Array<Int> = [];

    public function new(document:Document) {
        super(document, ElementID.Text);
    }

    override public function fillBoundingBox():lunasvg.Graphics.Rect {
        return boundingBox(false);
    }

    override public function strokeBoundingBox():lunasvg.Graphics.Rect {
        return boundingBox(true);
    }

    override public function layout(state:SVGLayoutState):Void {
        super.layout(state);
        new SVGTextFragmentsBuilder(m_text, m_fragments).build(this);
    }

    override public function render(state:SVGRenderState):Void {
        if (m_fragments.length == 0 || isVisibilityHidden() || isDisplayNone())
            return;
        var blendInfo = SVGBlendInfo.of(this);
        var newState = SVGRenderState.child(this, state, localTransform());
        newState.beginGroup(blendInfo);
        if (newState.mode() == Clipping) {
            newState.canvas().setColor(lunasvg.Graphics.Color.White);
        }

        for (fragment in m_fragments) {
            if (fragment.element.isVisibilityHidden())
                continue;
            var transform = newState.currentTransform().mul(Transform.rotated(fragment.angle, fragment.x, fragment.y)).mul(fragment.lengthAdjustTransform);
            var origin = new Point(fragment.x, fragment.y);

            var font = fragment.element.font();
            if (newState.mode() == Clipping) {
                newState.canvas().fillText(m_text, fragment.offset, fragment.length, font, origin, transform);
            } else {
                var fill = fragment.element.fill();
                var stroke = fragment.element.stroke();
                var stroke_width = fragment.element.strokeWidth();
                if (fill.applyPaint(newState))
                    newState.canvas().fillText(m_text, fragment.offset, fragment.length, font, origin, transform);
                if (stroke.applyPaint(newState)) {
                    newState.canvas().strokeText(m_text, fragment.offset, fragment.length, stroke_width, font, origin, transform);
                }
            }
        }

        newState.endGroup(blendInfo);
    }

    function boundingBox(includeStroke:Bool):lunasvg.Graphics.Rect {
        var boundingBox = lunasvg.Graphics.Rect.invalid();
        for (fragment in m_fragments) {
            var font = fragment.element.font();
            var stroke = fragment.element.stroke();
            var fragmentTranform = Transform.rotated(fragment.angle, fragment.x, fragment.y).mul(fragment.lengthAdjustTransform);
            var fragmentRect = new lunasvg.Graphics.Rect(fragment.x, f32(fragment.y - font.ascent()), fragment.width, fragment.height);
            if (includeStroke && stroke.isRenderable()) {
                var d = f32(fragment.element.strokeWidth() / 2);
                fragmentRect.inflate(d, d);
            }
            boundingBox.unite(fragmentTranform.mapRect(fragmentRect));
        }

        if (!boundingBox.isValid())
            boundingBox = lunasvg.Graphics.Rect.empty();
        return boundingBox;
    }

}
