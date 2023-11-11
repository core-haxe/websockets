package ws.impl.nodejs;

import ws.impl.Types.MessageType;
import ws.externs.nodejs.WebSocket as NativeWebSocket;
import haxe.io.Bytes;
import js.lib.Uint8Array;

@:noCompletion
class WebSocket extends WebSocketBase {
    private var nativeWebSocket:NativeWebSocket = null;

    public function new(url:String) {
        super();
        nativeWebSocket = new NativeWebSocket(url);
    }

    private var _onopen:Void->Void;
    public var onopen(null, set):Void->Void;
    private function set_onopen(value:Void->Void):Void->Void {
        _onopen = value;
        nativeWebSocket.on("open", (_) -> {
            if (_onopen != null) {
                _onopen();
            }
        });
        return value;
    }

    private var _onclose:Void->Void;
    public var onclose(null, set):Void->Void;
    private function set_onclose(value:Void->Void):Void->Void {
        _onclose = value;
        nativeWebSocket.on("close", (_) -> {
            if (_onclose != null) {
                _onclose();
            }
        });
        return value;
    }

    private var _onerror:Dynamic->Void;
    public var onerror(null, set):Dynamic->Void;
    private function set_onerror(value:Dynamic->Void):Dynamic->Void {
        _onerror = value;
        nativeWebSocket.on("error", (error) -> {
            if (_onerror != null) {
                _onerror(error);
            }
        });
        return value;
    }

    private var _onmessage:MessageType->Void;
    public var onmessage(null, set):MessageType->Void;
    private function set_onmessage(value:MessageType->Void):MessageType->Void {
        _onmessage = value;
        nativeWebSocket.on("message", (message:Dynamic, isBinary) -> {
            if (_onmessage != null) {
                if (isBinary) {
                    var binaryData:Uint8Array = message;
                    // TODO: must be a better way to convert Uint8Array -> Bytes (Bytes.ofData(binaryData.buffer) creates additional bytes at the start)
                    var bytes:Bytes = Bytes.alloc(binaryData.length);
                    var n = 0;
                    for (i in binaryData) {
                        bytes.set(n, i);
                        n++;
                    }
                    _onmessage(BytesMessage(bytes));
                } else {
                    _onmessage(StrMessage(message));
                }                
            }
        });
        return value;
    }

    public function send(data:Any) {
        if (data is Bytes) {
            var buffer = js.node.Buffer.hxFromBytes(data);
            nativeWebSocket.send(buffer, {binary: true});
        } else {
            nativeWebSocket.send(data);
        }
    }

    public function close() {
        nativeWebSocket.close();
    }
}