package ws.server;

#if nodejs

typedef WebSocketServer = ws.server.impl.nodejs.WebSocketServer;

#elseif sys

typedef WebSocketServer = ws.server.impl.sys.WebSocketServer;

#end