package ws.impl.js;

import ws.impl.Types.BinaryType;
import ws.impl.Types.MessageType;

import haxe.Constraints.Function;
import haxe.io.Bytes;

#if (haxe_ver < 4)
    typedef JsBuffer = js.html.ArrayBuffer;
#else
    typedef JsBuffer = js.lib.ArrayBuffer;
#end

@:noCompletion
class WebSocket extends WebSocketBase {
    private var _url:String;
    private var _ws:js.html.WebSocket = null;

    public function new(url:String, immediateOpen=true) {
        super();
        _url = url;
        if (immediateOpen) {
            open();
        }
    }

    private function createSocket() {
        return new js.html.WebSocket(_url);
    }

    public function open() {
        if (_ws != null) {
            throw "Socket already connected";
        }
        _ws = createSocket();
        set_binaryType(Types.BinaryType.ARRAYBUFFER);
        if (_onopenbeforeready != null) {
            onopen = _onopenbeforeready;
            _onopenbeforeready = null;
        }
        if (_onclosebeforeready != null) {
            onclose = _onclosebeforeready;
            _onclosebeforeready = null;
        }
        if (_onerrorbeforeready != null) {
            onerror = _onerrorbeforeready;
            _onerrorbeforeready = null;
        }
        if (_onmessagebeforeready != null) {
            onmessage = _onmessagebeforeready;
            _onmessagebeforeready = null;
        }
    }

    private var _onopenbeforeready:Function = null;
    public var onopen(get, set):Function;
    private function get_onopen():Function {
        return _ws.onopen;
    }
    private function set_onopen(value:Function):Function {
        if (_ws == null) {
            _onopenbeforeready = value;
            return value;
        }
        _ws.onopen = value;
        return value;
    }

    private var _onclosebeforeready:Function = null;
    private var _onclose:Function = null;
    public var onclose(get, set):Function;
    private function get_onclose():Function {
        return _onclose;
    }
    private function set_onclose(value:Function):Function {
        if (_ws == null) {
            _onclosebeforeready = value;
            return value;
        }
        _onclose = value;
        _ws.onclose = onCloseInternal;
        return value;
    }

    private function onCloseInternal() {
        trace("close internal");
        if (_onclose != null) {
            _onclose();
        }
        reset(true);
    }

    private var _onerrorbeforeready:Function = null;
    public var onerror(get, set):Function;
    private function get_onerror():Function {
        return _ws.onerror;
    }
    private function set_onerror(value:Function):Function {
        if (_ws == null) {
            _onerrorbeforeready = value;
            return value;
        }
        _ws.onerror = value;
        return value;
    }

    private var _onmessagebeforeready:Function = null;
    private var _onmessage:Function = null;
    public var onmessage(get, set):Function;
    private function get_onmessage():Function {
        return _onmessage;
    }
    private function set_onmessage(value:Function):Function {
        if (_ws == null) {
            _onmessagebeforeready = value;
            return value;
        }
        _onmessage = value;
        _ws.onmessage = function(message: Dynamic) {
            if (_onmessage != null) {
                if (Std.is(message.data, JsBuffer)) {
                    _onmessage(BytesMessage(Bytes.ofData(message.data)));
                } else {
                    _onmessage(StrMessage(message.data));
                }
            }
        };
        return value;
    }

    public var binaryType(get, set):BinaryType;
    private function get_binaryType() {
        return _ws.binaryType;
    }
    private function set_binaryType(value:BinaryType):BinaryType {
        _ws.binaryType = value;
        return value;
    }

    public function close() {
        _ws.close();
        reset(false);
    }

    private function reset(resetClose:Bool = true) {
        onopen = null;
        if (resetClose) {
            onclose = null;
            _onclose = null;
        }
        onerror = null;
        onmessage = null;
        _onmessage = null;
        _ws = null;
    }

    public function send(msg:Any) {
        if (Std.is(msg, Bytes)) {
            var bytes = cast(msg, Bytes);
            _ws.send(bytes.getData());
        } else if (Std.is(msg, Buffer)) {
            var buffer = cast(msg, Buffer);
            _ws.send(buffer.readAllAvailableBytes().getData());
        } else {
            _ws.send(msg);
        }
    }
}