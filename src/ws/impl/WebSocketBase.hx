package ws.impl;

@:noCompletion
class WebSocketBase
    #if sys
    extends WebSocketCommon
    #end
    {

    #if sys    
    public function new(socket:Socket) {
        super(socket);
    }
    #else
    public function new() {
    }
    #end
}