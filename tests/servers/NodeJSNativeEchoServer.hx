package servers;

import haxe.Timer;
import promises.Promise;
#if nodejs
import js.node.util.TextDecoder;
import js.lib.Uint8Array;
import ws.externs.nodejs.WebSocketServer as NativeWebSocketServer;
#elseif sys
import sys.io.Process;
#end

class NodeJSNativeEchoServer {
    #if nodejs
    static var server:NativeWebSocketServer;
    #end

    static function main() {
        #if nodejs

        var portString = Sys.args()[0];
        Sys.println("starting nodejs web socket server on port " + portString);
        server = new NativeWebSocketServer({port: Std.parseInt(portString)});
        server.on("connection", (ws, req) -> {
            var ip = req.socket.remoteAddress;
            Sys.println("incoming connection from: " + ip);
            ws.on("message", (data, isBinary) -> {
                if (isBinary) {
                    var binaryData:Uint8Array = data;
                    Sys.println("recv'd binary message (length = " + binaryData.length + ")");
                    ws.send(binaryData, {binary: true});
                } else {
                    Sys.println("recv'd message (length = " + data.length + ")");
                    ws.send("echo: " + data);
                }
            });
            ws.on("close", (_) -> {
                ws.terminate();
                Sys.println("closed");
            });
        });

        #end
    }

    #if nodejs
    private static var serverProcess:Dynamic;
    #elseif sys
    private static var serverProcess:Process;
    #end
    public static function run(port:Int):Promise<Bool> {
        return new Promise((resolve, reject) -> {

            #if nodejs
            serverProcess = js.node.ChildProcess.spawn("node", ["build/nodejs/echo-server.js", "" + port]);
            /*
            serverProcess.stdout.on("data", (data) -> {
                if (StringTools.trim(Std.string(data)).length == 0) {
                    return;
                }
                Sys.println(StringTools.trim("ECHO SERVER > " + data));
            });
            serverProcess.stderr.on("data", (data) -> {
                if (StringTools.trim(Std.string(data)).length == 0) {
                    return;
                }
                Sys.println(StringTools.trim("ECHO SERVER > " + data));
            });
            */
            serverProcess.on("error", (e) -> {
                reject(e);
            });
            /*
            serverProcess.on("close", (code) -> {
                Sys.println(StringTools.trim("ECHO SERVER > closed"));
            });
            */
    
            Timer.delay(() -> {
                resolve(true);
            }, 100);

            #elseif sys

            _stop = false;
            _stopped = false;
            sys.thread.Thread.create(() -> {
                var p = new Process("node", ["build/nodejs/echo-server.js", "" + port]);
                serverProcess = p;
                while (!_stop) {
                    /*
                    try {
                        var data = p.stdout.readLine();
                        if (StringTools.trim(Std.string(data)).length > 0) {
                            Sys.println(StringTools.trim("ECHO SERVER > " + data));
                        }
                    } catch (e:Dynamic) {
                    }
                    */
                    Sys.sleep(0.01);
                }

                //p.close();
                p.kill();
                _stopped = true;
            });
          
            Timer.delay(() -> {
                resolve(true);
            }, 100);

            #else

            resolve(true);

            #end
        });
    }

    #if sys
    private static var _stop:Bool = false;
    private static var _stopped:Bool = true;
    #end
    public static function kill():Promise<Bool> {
        return new Promise((resolve, reject) -> {

            #if nodejs

            if (serverProcess != null) {
                serverProcess.kill();   
            }
            resolve(true);

            #elseif sys

            if (_stopped == true) {
                resolve(true);
            } else {
                _stop = true;
                while (true) {
                    var b = _stopped;
                    if (b) {
                        break;
                    }
                    Sys.sleep(.1);
                }
                resolve(true);
            }

            #else 

            resolve(true);

            #end
        });
    }
}