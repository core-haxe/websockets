package cases;

import haxe.io.Bytes;
import utest.Async;
import servers.NodeJSNativeEchoServer;
import utest.Assert;
import utest.ITest;
import ws.WebSocket;
import ws.impl.Types.MessageType;
import DebugUtils.*;

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
        var start1 = Sys.time();
        var start2 = Sys.time();

        printHeader("testEcho");

        var client = new WebSocket("ws://localhost:7072");
        client.onopen = () -> {
            start2 = Sys.time();
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
                    printRow("messaging took", Math.round((Sys.time() - start2) * 1000));
                    printRow("total test took", Math.round((Sys.time() - start1) * 1000), true);
                    client.close();
                    async.done();
                case _:   
            }
        }
    }

    function testEcho_Large(async:Async) {
        var start1 = Sys.time();
        var start2 = Sys.time();

        printHeader("testEcho_Large");

        var client = new WebSocket("ws://localhost:7072");
        var sb = new StringBuf();
        for (_ in 0...1024) {
            sb.add("data ");
        }
        var message = sb.toString();
        client.onopen = () -> {
            start2 = Sys.time();
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
                    printRow("messaging took", Math.round((Sys.time() - start2) * 1000));
                    printRow("total test took", Math.round((Sys.time() - start1) * 1000), true);
                    client.close();
                    async.done();
                case _:   
            }
        }
    }

    function testEcho_Huge(async:Async) {
        var start1 = Sys.time();
        var start2 = Sys.time();

        printHeader("testEcho_Huge");

        var client = new WebSocket("ws://localhost:7072");
        var sb = new StringBuf();
        for (_ in 0...10240) {
            sb.add("data ");
        }
        var message = sb.toString();
        client.onopen = () -> {
            start2 = Sys.time();
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
                    printRow("messaging took", Math.round((Sys.time() - start2) * 1000));
                    printRow("total test took", Math.round((Sys.time() - start1) * 1000), true);
                    client.close();
                    async.done();
                case _:   
            }
        }
    }

    #if !cs // TODO: for some reason sending a huge buffer on cs seems to hang, it does get there _eventually_ but it takes ages (look at socket.flush in haxe maybe?)
    function testEcho_Massive(async:Async) {
        var start1 = Sys.time();
        var start2 = Sys.time();

        printHeader("testEcho_Massive");

        var client = new WebSocket("ws://localhost:7072");
        var sb = new StringBuf();
        for (_ in 0...102400) {
            sb.add("data ");
        }
        var message = sb.toString();
        client.onopen = () -> {
            start2 = Sys.time();
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
                    printRow("messaging took", Math.round((Sys.time() - start2) * 1000));
                    printRow("total test took", Math.round((Sys.time() - start1) * 1000), true);
                    client.close();
                    async.done();
                case _:   
            }
        }
    }
    #end

    function testBinary(async:Async) {
        var start1 = Sys.time();
        var start2 = Sys.time();

        printHeader("testBinary");

        var client = new WebSocket("ws://localhost:7072");
        client.onopen = () -> {
            start2 = Sys.time();
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
                    printRow("messaging took", Math.round((Sys.time() - start2) * 1000));
                    printRow("total test took", Math.round((Sys.time() - start1) * 1000), true);
                    client.close();
                    async.done();
                case _:   
            }
        }
    }

    function testBinary_Random(async:Async) {
        var start1 = Sys.time();
        var start2 = Sys.time();

        printHeader("testBinary_Random");

        var size = 1024;
        var randomBytes = Bytes.alloc(size);
        for (i in 0...size) {
            randomBytes.set(i, Std.random(0xffffff));
        }
        var client = new WebSocket("ws://localhost:7072");
        client.onopen = () -> {
            start2 = Sys.time();
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
                    printRow("messaging took", Math.round((Sys.time() - start2) * 1000));
                    printRow("total test took", Math.round((Sys.time() - start1) * 1000), true);
                    client.close();
                    async.done();
                case _:   
            }
        }
    }

    #if !cs // TODO: for some reason sending a huge buffer on cs seems to hang, it does get there _eventually_ but it takes ages (look at socket.flush in haxe maybe?)
    function testBinary_Random_Huge(async:Async) {
        var start1 = Sys.time();
        var start2 = Sys.time();

        printHeader("testBinary_Random_Huge");

        var size = 102400;
        var randomBytes = Bytes.alloc(size);
        for (i in 0...size) {
            randomBytes.set(i, Std.random(0xffffff));
        }
        var client = new WebSocket("ws://localhost:7072");
        client.onopen = () -> {
            start2 = Sys.time();
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
                    printRow("messaging took", Math.round((Sys.time() - start2) * 1000));
                    printRow("total test took", Math.round((Sys.time() - start1) * 1000), true);
                    client.close();
                    async.done();
                case _:   
            }
        }
    }
    #end

    #if !cs // TODO: for some reason sending a huge buffer on cs seems to hang, it does get there _eventually_ but it takes ages (look at socket.flush in haxe maybe?)
    function testBinary_Random_Massive(async:Async) {
        var start1 = Sys.time();
        var start2 = Sys.time();

        printHeader("testBinary_Random_Massive");

        var size = 1024000;
        var randomBytes = Bytes.alloc(size);
        for (i in 0...size) {
            randomBytes.set(i, Std.random(0xffffff));
        }
        var client = new WebSocket("ws://localhost:7072");
        client.onopen = () -> {
            start2 = Sys.time();
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
                    printRow("messaging took", Math.round((Sys.time() - start2) * 1000));
                    printRow("total test took", Math.round((Sys.time() - start1) * 1000), true);
                    client.close();
                    async.done();
                case _:   
            }
        }
    }
    #end

    function testBinary_Random_With_Zeros(async:Async) {
        var start1 = Sys.time();
        var start2 = Sys.time();

        printHeader("testBinary_Random_With_Zeros");

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
            start2 = Sys.time();
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
                    printRow("messaging took", Math.round((Sys.time() - start2) * 1000));
                    printRow("total test took", Math.round((Sys.time() - start1) * 1000), true);
                    client.close();
                    async.done();
                case _:   
            }
        }
    }

    function testClientClose(async:Async) {
        var start1 = Sys.time();
        var start2 = Sys.time();

        printHeader("testClientClose");

        var client = new WebSocket("ws://localhost:7072");
        client.onopen = () -> {
            start2 = Sys.time();
            client.close();
        }
        client.onerror = (e) -> {
            Assert.fail("error encountered", e);
            async.done();
        }
        client.onclose = () -> {
            printRow("messaging took", Math.round((Sys.time() - start2) * 1000));
            printRow("total test took", Math.round((Sys.time() - start1) * 1000), true);
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