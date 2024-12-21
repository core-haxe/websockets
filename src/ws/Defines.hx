package ws;

class Defines {
    public macro static function bufferSize() {
        var value = haxe.macro.Context.definedValue("websockets-buffer-size");
        if (value == null) {
            value = "1024";
        }
        return macro $v{Std.parseInt(value)};
    }
}