// Ported from lunasvg 3.5.0: include/lunasvg.h, source/lunasvg.cpp (Box)
// Original code Copyright (c) 2020-2026 Samuel Ugochukwu, licensed under MIT.
// Modified: translated from C++ to Haxe. See LICENSE.
package lunasvg;

import plutovg.Utils.f32;

/**
 * An axis-aligned box (`lunasvg::Box`).
 */
class Box {

    public var x:Float;

    public var y:Float;

    public var w:Float;

    public var h:Float;

    public function new(x:Float = 0, y:Float = 0, w:Float = 0, h:Float = 0) {
        this.x = f32(x);
        this.y = f32(y);
        this.w = f32(w);
        this.h = f32(h);
    }

    public static function fromRect(rect:lunasvg.Graphics.Rect):Box {
        return new Box(rect.x, rect.y, rect.w, rect.h);
    }

    /**
     * Transforms this box by `matrix` (bounding box of the result).
     */
    public function transform(matrix:Matrix):Box {
        var b = transformed(matrix);
        x = b.x;
        y = b.y;
        w = b.w;
        h = b.h;
        return this;
    }

    public function transformed(matrix:Matrix):Box {
        return Box.fromRect(lunasvg.Graphics.Transform.fromPublicMatrix(matrix).mapRect(lunasvg.Graphics.Rect.fromBox(this)));
    }

    public function toString():String {
        return 'Box($x, $y, $w, $h)';
    }

}
