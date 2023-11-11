package ws.externs.nodejs;

import haxe.Constraints.Function;

@:jsRequire("ws", "WebSocket")
@:noCompletion
extern class WebSocket {
    public function new(url:String);
    public function on(event:String, callback:Function):Void;
    public function send(data:Dynamic, options:Dynamic = null):Void;
    public function close():Void;
    public function terminate():Void;
}