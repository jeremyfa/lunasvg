package;

import haxe.io.Bytes;

/**
 * Minimal file access for the test runner (Node.js or sys targets).
 */
class Fs {

    #if js
    static var fs:Dynamic = js.Syntax.code("require('fs')");
    #end

    public static function readText(path:String):String {
        #if js
        return fs.readFileSync(path, "utf8");
        #else
        return sys.io.File.getContent(path);
        #end
    }

    public static function readBytes(path:String):Bytes {
        #if js
        var buf:Dynamic = fs.readFileSync(path);
        var ab:js.lib.ArrayBuffer = buf.buffer.slice(buf.byteOffset, buf.byteOffset + buf.length);
        return Bytes.ofData(ab);
        #else
        return sys.io.File.getBytes(path);
        #end
    }

    public static function writeBytes(path:String, bytes:Bytes):Void {
        #if js
        fs.writeFileSync(path, js.Syntax.code("Buffer.from({0})", bytes.getData()));
        #else
        sys.io.File.saveBytes(path, bytes);
        #end
    }

    public static function exists(path:String):Bool {
        #if js
        return fs.existsSync(path);
        #else
        return sys.FileSystem.exists(path);
        #end
    }

    public static function mkdir(path:String):Void {
        #if js
        if (!fs.existsSync(path))
            fs.mkdirSync(path, {recursive: true});
        #else
        sys.FileSystem.createDirectory(path);
        #end
    }

}
