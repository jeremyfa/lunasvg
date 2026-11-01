// Ported from lunasvg 3.5.0: include/lunasvg.h, source/lunasvg.cpp (Matrix)
// Original code Copyright (c) 2020-2026 Samuel Ugochukwu, licensed under MIT.
// Modified: translated from C++ to Haxe. See LICENSE.
package lunasvg;

import lunasvg.Graphics.Transform;
import plutovg.Utils.f32;

/**
 * A 2D affine matrix (`lunasvg::Matrix`): maps (x, y) to
 * (a * x + c * y + e, b * x + d * y + f). Mutating methods change this
 * matrix and return it.
 */
class Matrix {

    public var a:Float;

    public var b:Float;

    public var c:Float;

    public var d:Float;

    public var e:Float;

    public var f:Float;

    public function new(a:Float = 1, b:Float = 0, c:Float = 0, d:Float = 1, e:Float = 0, f:Float = 0) {
        this.a = f32(a);
        this.b = f32(b);
        this.c = f32(c);
        this.d = f32(d);
        this.e = f32(e);
        this.f = f32(f);
    }

    public static function fromTransform(transform:Transform):Matrix {
        var m = transform.matrix();
        return new Matrix(m.a, m.b, m.c, m.d, m.e, m.f);
    }

    public function clone():Matrix {
        return new Matrix(a, b, c, d, e, f);
    }

    function set(m:Matrix):Matrix {
        a = m.a;
        b = m.b;
        c = m.c;
        d = m.d;
        e = m.e;
        f = m.f;
        return this;
    }

    /**
     * `operator*`: returns `this * matrix` (`matrix` is applied first).
     */
    public function mul(matrix:Matrix):Matrix {
        return fromTransform(Transform.fromPublicMatrix(this).mul(Transform.fromPublicMatrix(matrix)));
    }

    public function multiply(matrix:Matrix):Matrix {
        return set(mul(matrix));
    }

    public function translate(tx:Float, ty:Float):Matrix {
        return multiply(translated(tx, ty));
    }

    public function scale(sx:Float, sy:Float):Matrix {
        return multiply(scaled(sx, sy));
    }

    /**
     * Rotates by `angle` degrees around (`cx`, `cy`).
     */
    public function rotate(angle:Float, cx:Float = 0, cy:Float = 0):Matrix {
        return multiply(rotated(angle, cx, cy));
    }

    /**
     * Shears by `shx` and `shy` degrees.
     */
    public function shear(shx:Float, shy:Float):Matrix {
        return multiply(sheared(shx, shy));
    }

    public function invert():Matrix {
        return set(inverse());
    }

    public function inverse():Matrix {
        return fromTransform(Transform.fromPublicMatrix(this).inverse());
    }

    public function reset():Void {
        set(new Matrix(1, 0, 0, 1, 0, 0));
    }

    public static function translated(tx:Float, ty:Float):Matrix {
        return fromTransform(Transform.translated(tx, ty));
    }

    public static function scaled(sx:Float, sy:Float):Matrix {
        return fromTransform(Transform.scaled(sx, sy));
    }

    public static function rotated(angle:Float, cx:Float = 0, cy:Float = 0):Matrix {
        return fromTransform(Transform.rotated(angle, cx, cy));
    }

    public static function sheared(shx:Float, shy:Float):Matrix {
        return fromTransform(Transform.sheared(shx, shy));
    }

    public function toString():String {
        return 'Matrix($a, $b, $c, $d, $e, $f)';
    }

}
