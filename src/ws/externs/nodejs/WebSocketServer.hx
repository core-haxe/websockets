package ws.externs.nodejs;

@:jsRequire("ws", "WebSocketServer")
@:noCompletion
extern class WebSocketServer {
    public function new(options:Dynamic);
    public function on(event:String, callback:WebSocket->Dynamic->Void):Void;
}