package ws.impl;

#if java

typedef Socket = ws.impl.java.NioSocket;

#elseif cs

typedef Socket = ws.impl.cs.NonBlockingSocket;

#elseif nodejs

typedef Socket = ws.impl.nodejs.NodeSocket;

#else

typedef Socket = sys.net.Socket;

#end