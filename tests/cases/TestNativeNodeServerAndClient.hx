package cases;

//import sys.io.Process;
import servers.NodeJSNativeEchoServer;
import utest.Assert;
import utest.Async;
import utest.ITest;
import ws.externs.nodejs.WebSocket as NativeWebSocket;

@:timeout(2000)
class TestNativeNodeServerAndClient implements ITest {
    public function new() {
    }

    function setupClass(async:Async):Void {
        NodeJSNativeEchoServer.run(7072).then(_ -> {
            async.done();
        }, error -> {
            trace(error);
            async.done();
        });
    }

    function teardownClass(async:Async):Void {
        NodeJSNativeEchoServer.kill().then(_ -> {
            async.done();
        }, error -> {
            trace(error);
            async.done();
        });
    }

    function testBasic(async:Async) {
        var client = new NativeWebSocket("ws://localhost:7072");
        client.on("open", (_) -> {
            client.send("message to server");
        });
        client.on("error", (error) -> {
            trace("error", error);
            async.done();
        });
        client.on("message", (data) -> {
            Assert.equals("echo: message to server", data);
            async.done();
        });
    }
}