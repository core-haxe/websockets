package cases;

import haxe.io.Bytes;
import haxe.Timer;
import utest.Async;
import servers.NodeJSNativeEchoServer;
import utest.Assert;
import utest.ITest;
import ws.WebSocket;
import ws.impl.Types.MessageType;

@:timeout(2000)
class TestClientWithNativeNodeServer implements ITest {
    public function new() {
    }

    function setup(async:Async):Void {
        NodeJSNativeEchoServer.run(7072).then(_ -> {
            async.done();
        }, error -> {
            Assert.fail("error encountered", error);
            async.done();
        });
    }

    function teardown(async:Async):Void {
        NodeJSNativeEchoServer.kill().then(_ -> {
            async.done();
        }, error -> {
            Assert.fail("error encountered", error);
            async.done();
        });
    }

    function testEcho(async:Async) {
        var client = new WebSocket("ws://localhost:7072");
        client.onopen = () -> {
            client.send("message to server");
        }
        client.onerror = (e) -> {
            Assert.fail("error encountered", e);
            async.done();
        }
        client.onmessage = (m) -> {
            switch (m) {
                case StrMessage(content):
                    Assert.equals("echo: message to server", content);
                    client.close();
                    async.done();
                case _:   
            }
        }
    }

    function testEcho_Large(async:Async) {
        var client = new WebSocket("ws://localhost:7072");
        var sb = new StringBuf();
        for (_ in 0...1024) {
            sb.add("data ");
        }
        var message = sb.toString();
        client.onopen = () -> {
            client.send(message);
        }
        client.onerror = (e) -> {
            Assert.fail("error encountered", e);
            async.done();
        }
        client.onmessage = (m) -> {
            switch (m) {
                case StrMessage(content):
                    Assert.equals("echo: " + message, content);
                    client.close();
                    async.done();
                case _:   
            }
        }
    }

    function testEcho_Huge(async:Async) {
        var client = new WebSocket("ws://localhost:7072");
        var sb = new StringBuf();
        for (_ in 0...10240) {
            sb.add("data ");
        }
        var message = sb.toString();
        client.onopen = () -> {
            client.send(message);
        }
        client.onerror = (e) -> {
            Assert.fail("error encountered", e);
            async.done();
        }
        client.onmessage = (m) -> {
            switch (m) {
                case StrMessage(content):
                    Assert.equals("echo: " + message, content);
                    client.close();
                    async.done();
                case _:   
            }
        }
    }

    #if !cs // TODO: for some reason sending a huge buffer on cs seems to hang, it does get there _eventually_ but it takes ages (look at socket.flush in haxe maybe?)
    function testEcho_Massive(async:Async) {
        var client = new WebSocket("ws://localhost:7072");
        var sb = new StringBuf();
        for (_ in 0...102400) {
            sb.add("data ");
        }
        var message = sb.toString();
        client.onopen = () -> {
            client.send(message);
        }
        client.onerror = (e) -> {
            Assert.fail("error encountered", e);
            async.done();
        }
        client.onmessage = (m) -> {
            switch (m) {
                case StrMessage(content):
                    Assert.equals("echo: " + message, content);
                    client.close();
                    async.done();
                case _:   
            }
        }
    }
    #end

    function testBinary(async:Async) {
        var client = new WebSocket("ws://localhost:7072");
        client.onopen = () -> {
            client.send(Bytes.ofString("this is a binary message"));
        }
        client.onerror = (e) -> {
            Assert.fail("error encountered", e);
            async.done();
        }
        client.onmessage = (m) -> {
            switch (m) {
                case StrMessage(_):
                    Assert.fail("shouldnt get a string message");
                    async.done();
                case BytesMessage(content):
                    Assert.equals(Bytes.ofString("this is a binary message").toString(), content.toString());
                    client.close();
                    async.done();
                case _:   
            }
        }
    }

    function testBinary_Random(async:Async) {
        var size = 1024;
        var randomBytes = Bytes.alloc(size);
        for (i in 0...size) {
            randomBytes.set(i, Std.random(0xffffff));
        }
        var client = new WebSocket("ws://localhost:7072");
        client.onopen = () -> {
            client.send(randomBytes);
        }
        client.onerror = (e) -> {
            Assert.fail("error encountered", e);
            async.done();
        }
        client.onmessage = (m) -> {
            switch (m) {
                case StrMessage(_):
                    Assert.fail("shouldnt get a string message");
                    async.done();
                case BytesMessage(content):
                    Assert.equals(randomBytes.length, content.length);
                    for (i in 0...content.length) {
                        if (randomBytes.get(i) != content.get(i)) {
                            Assert.fail("bytes not equal"); // we are doing it this way so we dont have 1000s of traces
                        }
                    }
                    client.close();
                    async.done();
                case _:   
            }
        }
    }

    #if !cs // TODO: for some reason sending a huge buffer on cs seems to hang, it does get there _eventually_ but it takes ages (look at socket.flush in haxe maybe?)
    function testBinary_Random_Huge(async:Async) {
        var size = 102400;
        var randomBytes = Bytes.alloc(size);
        for (i in 0...size) {
            randomBytes.set(i, Std.random(0xffffff));
        }
        var client = new WebSocket("ws://localhost:7072");
        client.onopen = () -> {
            client.send(randomBytes);
        }
        client.onerror = (e) -> {
            Assert.fail("error encountered", e);
            async.done();
        }
        client.onmessage = (m) -> {
            switch (m) {
                case StrMessage(_):
                    Assert.fail("shouldnt get a string message");
                    async.done();
                case BytesMessage(content):
                    Assert.equals(randomBytes.length, content.length);
                    for (i in 0...content.length) {
                        if (randomBytes.get(i) != content.get(i)) {
                            Assert.fail("bytes not equal"); // we are doing it this way so we dont have 1000s of traces
                        }
                    }
                    client.close();
                    async.done();
                case _:   
            }
        }
    }
    #end

    #if !cs // TODO: for some reason sending a huge buffer on cs seems to hang, it does get there _eventually_ but it takes ages (look at socket.flush in haxe maybe?)
    function testBinary_Random_Massive(async:Async) {
        var size = 1024000;
        var randomBytes = Bytes.alloc(size);
        for (i in 0...size) {
            randomBytes.set(i, Std.random(0xffffff));
        }
        var client = new WebSocket("ws://localhost:7072");
        client.onopen = () -> {
            client.send(randomBytes);
        }
        client.onerror = (e) -> {
            Assert.fail("error encountered", e);
            async.done();
        }
        client.onmessage = (m) -> {
            switch (m) {
                case StrMessage(_):
                    Assert.fail("shouldnt get a string message");
                    async.done();
                case BytesMessage(content):
                    Assert.equals(randomBytes.length, content.length);
                    for (i in 0...content.length) {
                        if (randomBytes.get(i) != content.get(i)) {
                            Assert.fail("bytes not equal"); // we are doing it this way so we dont have 1000s of traces
                        }
                    }
                    client.close();
                    async.done();
                case _:   
            }
        }
    }
    #end

    function testBinary_Random_With_Zeros(async:Async) {
        var size = 1024;
        var randomBytes = Bytes.alloc(size);
        for (i in 0...size) {
            if (i % 2 == 0) {
                randomBytes.set(i, 0);
            } else {
                randomBytes.set(i, Std.random(0xffffff));
            }
        }
        var client = new WebSocket("ws://localhost:7072");
        client.onopen = () -> {
            client.send(randomBytes);
        }
        client.onerror = (e) -> {
            Assert.fail("error encountered", e);
            async.done();
        }
        client.onmessage = (m) -> {
            switch (m) {
                case StrMessage(_):
                    Assert.fail("shouldnt get a string message");
                    async.done();
                case BytesMessage(content):
                    Assert.equals(randomBytes.length, content.length);
                    for (i in 0...content.length) {
                        if (randomBytes.get(i) != content.get(i)) {
                            Assert.fail("bytes not equal"); // we are doing it this way so we dont have 1000s of traces
                        }
                    }
                    client.close();
                    async.done();
                case _:   
            }
        }
    }

    function testClientClose(async:Async) {
        var client = new WebSocket("ws://localhost:7072");
        client.onopen = () -> {
            client.close();
        }
        client.onerror = (e) -> {
            Assert.fail("error encountered", e);
            async.done();
        }
        client.onclose = () -> {
            Assert.equals(1, 1);
            async.done();
        }
    }

    #if (!js || nodejs)
    /*
    function testServerClose(async:Async) {
        var client = new WebSocket("ws://localhost:7072");
        client.onopen = () -> {
            NodeJSNativeEchoServer.kill();
        }
        client.onerror = (e) -> {
            Assert.fail("error encountered", e);
            async.done();
        }
        client.onclose = () -> {
            Assert.equals(1, 1);
            async.done();
        }
    }
    */
    #end
}