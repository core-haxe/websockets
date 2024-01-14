package ws.impl.java;

import haxe.io.BytesBuffer;
import haxe.io.BytesOutput;
import java.nio.ByteBuffer;

@:access(ws.impl.java.NioSocket)
class NioSocketOutput extends BytesOutput {
    public var socket:NioSocket;

    public function new(socket:NioSocket) {
        super();
        this.socket = socket;
    }

    public override function flush() {
        var bytes = getBytes();
        var buffer = ByteBuffer.wrap(bytes.getData());
        socket.channel.write(buffer);
        buffer.clear();
        b = new BytesBuffer();
    }
}
