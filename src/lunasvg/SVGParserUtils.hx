// Ported from lunasvg 3.5.0: source/svgparserutils.h
// Original code Copyright (c) 2020-2026 Samuel Ugochukwu, licensed under MIT.
// Modified: translated from C++ to Haxe. See LICENSE.
package lunasvg;

import plutovg.Utils.f32;

/**
 * A mutable window over a string (`std::string_view`). Characters are read
 * as code units with `StringTools.fastCodeAt()`.
 */
class StringView {

    public var data:String;

    public var pos:Int;

    public var end:Int;

    public inline function new(data:String, pos:Int = 0, ?end:Int) {
        this.data = data;
        this.pos = pos;
        this.end = end != null ? end : data.length;
    }

    public inline function clone():StringView {
        return new StringView(data, pos, end);
    }

    public inline function empty():Bool {
        return pos >= end;
    }

    public inline function length():Int {
        return end - pos;
    }

    public inline function front():Int {
        return StringTools.fastCodeAt(data, pos);
    }

    public inline function back():Int {
        return StringTools.fastCodeAt(data, end - 1);
    }

    public inline function at(index:Int):Int {
        return StringTools.fastCodeAt(data, pos + index);
    }

    public inline function removePrefix(n:Int):Void {
        pos += n;
    }

    public inline function removeSuffix(n:Int):Void {
        end -= n;
    }

    /**
     * `substr(start, count)`; a negative or too large `count` means "to the
     * end".
     */
    public function substr(start:Int, count:Int = -1):StringView {
        var b = pos + start;
        if (b > end)
            b = end;
        var e = (count < 0 || b + count > end) ? end : b + count;
        return new StringView(data, b, e);
    }

    /**
     * Index (relative to `pos`) of the first occurrence of the character
     * `c` from `from`, or -1 (`npos`).
     */
    public function findChar(c:Int, from:Int = 0):Int {
        var i = pos + from;
        while (i < end) {
            if (StringTools.fastCodeAt(data, i) == c)
                return i - pos;
            i++;
        }
        return -1;
    }

    /**
     * Index (relative to `pos`) of the first occurrence of `s`, or -1.
     */
    public function find(s:String, from:Int = 0):Int {
        var index = data.indexOf(s, pos + from);
        if (index < 0 || index + s.length > end)
            return -1;
        return index - pos;
    }

    public function equals(s:String):Bool {
        var n = s.length;
        if (n != end - pos)
            return false;
        for (i in 0...n) {
            if (StringTools.fastCodeAt(s, i) != StringTools.fastCodeAt(data, pos + i))
                return false;
        }
        return true;
    }

    public function startsWith(s:String):Bool {
        var n = s.length;
        if (n > end - pos)
            return false;
        for (i in 0...n) {
            if (StringTools.fastCodeAt(s, i) != StringTools.fastCodeAt(data, pos + i))
                return false;
        }
        return true;
    }

    public inline function toString():String {
        return data.substring(pos, end);
    }

}

/**
 * Parsing helpers (svgparserutils.h). Functions taking a `StringView`
 * consume what they parse, like the C++ ones taking `std::string_view&`.
 */
class SVGParserUtils {

    public static inline function IS_NUM(cc:Int):Bool {
        return cc >= '0'.code && cc <= '9'.code;
    }

    public static inline function IS_ALPHA(cc:Int):Bool {
        return (cc >= 'a'.code && cc <= 'z'.code) || (cc >= 'A'.code && cc <= 'Z'.code);
    }

    public static inline function IS_WS(cc:Int):Bool {
        return cc == ' '.code || cc == '\t'.code || cc == '\n'.code || cc == '\r'.code;
    }

    public static function stripLeadingSpaces(input:StringView):Void {
        while (!input.empty() && IS_WS(input.front())) {
            input.removePrefix(1);
        }
    }

    public static function stripTrailingSpaces(input:StringView):Void {
        while (!input.empty() && IS_WS(input.back())) {
            input.removeSuffix(1);
        }
    }

    public static function stripLeadingAndTrailingSpaces(input:StringView):Void {
        stripLeadingSpaces(input);
        stripTrailingSpaces(input);
    }

    public static function skipOptionalSpaces(input:StringView):Bool {
        while (!input.empty() && IS_WS(input.front()))
            input.removePrefix(1);
        return !input.empty();
    }

    public static function skipOptionalSpacesOrDelimiter(input:StringView, delimiter:Int):Bool {
        if (!input.empty() && !IS_WS(input.front()) && delimiter != input.front())
            return false;
        if (skipOptionalSpaces(input)) {
            if (delimiter == input.front()) {
                input.removePrefix(1);
                skipOptionalSpaces(input);
            }
        }

        return !input.empty();
    }

    public static inline function skipOptionalSpacesOrComma(input:StringView):Bool {
        return skipOptionalSpacesOrDelimiter(input, ','.code);
    }

    public static function skipDelimiterAndOptionalSpaces(input:StringView, delimiter:Int):Bool {
        if (!input.empty() && input.front() == delimiter) {
            input.removePrefix(1);
            skipOptionalSpaces(input);
            return true;
        }

        return false;
    }

    public static function skipDelimiter(input:StringView, delimiter:Int):Bool {
        if (!input.empty() && input.front() == delimiter) {
            input.removePrefix(1);
            return true;
        }

        return false;
    }

    public static function skipString(input:StringView, value:String):Bool {
        if (input.startsWith(value)) {
            input.removePrefix(value.length);
            return true;
        }

        return false;
    }

    public static function isIntegralDigit(ch:Int, base:Int):Bool {
        if (IS_NUM(ch))
            return ch - '0'.code < base;
        if (IS_ALPHA(ch))
            return (ch >= 'a'.code && ch < 'a'.code + base - 10) || (ch >= 'A'.code && ch < 'A'.code + base - 10);
        return false;
    }

    public static function toIntegralDigit(ch:Int):Int {
        if (IS_NUM(ch))
            return ch - '0'.code;
        if (ch >= 'a'.code)
            return ch - 'a'.code + 10;
        return ch - 'A'.code + 10;
    }

    /**
     * `parseInteger<unsigned int>()`: returns the value, or -1 on failure
     * (the value is limited to 0x7FFFFFFF here).
     */
    public static function parseInteger(input:StringView, base:Int = 10):Int {
        var intMax = 0x7FFFFFFF;
        var maxMultiplier = Std.int(intMax / base);
        var value = 0;
        if (!input.empty() && input.front() == '+'.code) {
            input.removePrefix(1);
        }

        if (input.empty() || !isIntegralDigit(input.front(), base))
            return -1;
        do {
            var digitValue = toIntegralDigit(input.front());
            if (value > maxMultiplier || (value == maxMultiplier && digitValue > (intMax % base)))
                return -1;
            value = base * value + digitValue;
            input.removePrefix(1);
        } while (!input.empty() && isIntegralDigit(input.front(), base));
        return value;
    }

    static inline final FLOAT_MAX:Float = 3.40282346638528859811704183484516925440e+38;

    /**
     * `parseNumber<float>()`, computed in float32 like the C++ template.
     * Returns NaN on failure.
     */
    public static function parseNumber(input:StringView):Float {
        var integer = 0.0;
        var fraction = 0.0;
        var exponent = 0;
        var sign = 1;
        var expsign = 1;

        if (!input.empty() && input.front() == '+'.code) {
            input.removePrefix(1);
        } else if (!input.empty() && input.front() == '-'.code) {
            input.removePrefix(1);
            sign = -1;
        }

        if (input.empty() || (!IS_NUM(input.front()) && input.front() != '.'.code))
            return Math.NaN;
        if (IS_NUM(input.front())) {
            do {
                integer = f32(f32(10 * integer) + (input.front() - '0'.code));
                input.removePrefix(1);
            } while (!input.empty() && IS_NUM(input.front()));
        }

        if (!input.empty() && input.front() == '.'.code) {
            input.removePrefix(1);
            if (input.empty() || !IS_NUM(input.front()))
                return Math.NaN;
            var divisor = 1.0;
            do {
                fraction = f32(f32(10 * fraction) + (input.front() - '0'.code));
                divisor = f32(divisor * 10);
                input.removePrefix(1);
            } while (!input.empty() && IS_NUM(input.front()));
            fraction = f32(fraction / divisor);
        }

        if (input.length() > 1 && (input.at(0) == 'e'.code || input.at(0) == 'E'.code)
            && (input.at(1) != 'x'.code && input.at(1) != 'm'.code)) {
            input.removePrefix(1);
            if (!input.empty() && input.front() == '+'.code)
                input.removePrefix(1);
            else if (!input.empty() && input.front() == '-'.code) {
                input.removePrefix(1);
                expsign = -1;
            }

            if (input.empty() || !IS_NUM(input.front()))
                return Math.NaN;
            do {
                exponent = 10 * exponent + (input.front() - '0'.code);
                input.removePrefix(1);
            } while (!input.empty() && IS_NUM(input.front()));
        }

        var number = f32(sign * f32(integer + fraction));
        if (exponent != 0)
            number = f32(number * f32(Math.pow(10.0, expsign * exponent)));
        if (number >= -FLOAT_MAX && number <= FLOAT_MAX)
            return number;
        return Math.NaN;
    }

}
