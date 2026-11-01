// Ported from lunasvg 3.5.0: source/svgrenderstate.h, source/svgrenderstate.cpp
// Original code Copyright (c) 2020-2026 Samuel Ugochukwu, licensed under MIT.
// Modified: translated from C++ to Haxe. See LICENSE.
package lunasvg;

import lunasvg.Graphics;
import lunasvg.SVGElement;

enum abstract SVGRenderMode(Int) from Int to Int {
    var Painting;
    var Clipping;
}

class SVGBlendInfo {

    var m_clipper:Null<SVGClipPathElement>;

    var m_masker:Null<SVGMaskElement>;

    var m_opacity:Float;

    public function new(clipper:Null<SVGClipPathElement>, masker:Null<SVGMaskElement>, opacity:Float) {
        m_clipper = clipper;
        m_masker = masker;
        m_opacity = opacity;
    }

    public static inline function of(element:SVGElement):SVGBlendInfo {
        return new SVGBlendInfo(element.clipper(), element.masker(), element.opacity());
    }

    public function requiresCompositing(mode:SVGRenderMode):Bool {
        return (m_clipper != null && m_clipper.requiresMasking()) || (mode == Painting && (m_masker != null || m_opacity < 1));
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

}

/**
 * The state of a render pass: element, parent state, current transform,
 * mode and target canvas (`SVGRenderState`). In C++ `state->` reaches the
 * canvas: here it is `state.canvas()`.
 */
class SVGRenderState {

    var m_element:Null<SVGElement>;

    var m_parent:Null<SVGRenderState>;

    var m_currentTransform:Transform;

    var m_mode:SVGRenderMode;

    var m_canvas:Canvas;

    public function new(element:Null<SVGElement>, parent:Null<SVGRenderState>, currentTransform:Transform, mode:SVGRenderMode, canvas:Canvas) {
        m_element = element;
        m_parent = parent;
        m_currentTransform = currentTransform;
        m_mode = mode;
        m_canvas = canvas;
    }

    /**
     * `SVGRenderState(element, parent, localTransform)`: a child state
     * drawing on the canvas of `parent`.
     */
    public static function child(element:SVGElement, parent:SVGRenderState, localTransform:Transform):SVGRenderState {
        return new SVGRenderState(element, parent, parent.currentTransform().mul(localTransform), parent.mode(), parent.canvas());
    }

    public inline function element():Null<SVGElement> {
        return m_element;
    }

    public inline function parent():Null<SVGRenderState> {
        return m_parent;
    }

    /**
     * The current transform (shared: clone it before changing it).
     */
    public inline function currentTransform():Transform {
        return m_currentTransform;
    }

    public inline function mode():SVGRenderMode {
        return m_mode;
    }

    public inline function canvas():Canvas {
        return m_canvas;
    }

    public function fillBoundingBox():Rect {
        return m_element.fillBoundingBox();
    }

    public function paintBoundingBox():Rect {
        return m_element.paintBoundingBox();
    }

    public function hasCycleReference(element:SVGElement):Bool {
        var current = this;
        do {
            if (element == current.element())
                return true;
            current = current.parent();
        } while (current != null);
        return false;
    }

    public function beginGroup(blendInfo:SVGBlendInfo):Void {
        var requiresCompositing = blendInfo.requiresCompositing(m_mode);
        if (requiresCompositing) {
            var boundingBox = m_currentTransform.mapRect(m_element.paintBoundingBox());
            boundingBox.intersect(m_canvas.extents());
            m_canvas = Canvas.createFromRect(boundingBox);
        } else {
            m_canvas.save();
        }

        if (!requiresCompositing && blendInfo.clipper() != null) {
            blendInfo.clipper().applyClipPath(this);
        }
    }

    public function endGroup(blendInfo:SVGBlendInfo):Void {
        if (m_canvas == m_parent.canvas()) {
            m_canvas.restore();
            return;
        }

        var opacity = m_mode == Clipping ? 1.0 : blendInfo.opacity();
        if (blendInfo.clipper() != null)
            blendInfo.clipper().applyClipMask(this);
        if (m_mode == Painting && blendInfo.masker() != null) {
            blendInfo.masker().applyMask(this);
        }

        m_parent.m_canvas.blendCanvas(m_canvas, Src_Over, opacity);
    }

}
