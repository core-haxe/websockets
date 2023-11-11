package ws;

#if nodejs

typedef WebSocket = ws.impl.nodejs.WebSocket;

#elseif js

typedef WebSocket = ws.impl.js.WebSocket;

#elseif sys

typedef WebSocket = ws.impl.sys.WebSocket;

#end