package format.tools;

/**
 * Test-only replacement of format.tools.Inflate (format library): always
 * uses the pure Haxe inflater. On hxcpp, the native zlib wrapper used by
 * the original crashed in the GC finalizers after a failed decode.
 */
class Inflate {

    public static function run(bytes:haxe.io.Bytes):haxe.io.Bytes {
        return haxe.zip.InflateImpl.run(new haxe.io.BytesInput(bytes));
    }

}
