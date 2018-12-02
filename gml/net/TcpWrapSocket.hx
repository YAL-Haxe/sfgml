package gml.net;
import gml.io.Buffer;

/**
 * ...
 * @author YellowAfterlife
 */
abstract TcpWrapSocket(Socket) {
	public static inline var defValue:TcpWrapSocket = cast -1;
	//
	public inline function new() {
		this = Socket.createClient(SocketType.TCP);
	}
	public inline function destroy():Void {
		this.destroy();
	}
	public static inline function createAt(port:Int):TcpWrapSocket {
		return cast Socket.createClientAt(SocketType.TCP, port);
	}
	public static inline function createServer(port:Int, maxClients:Int):TcpWrapSocket {
		return cast Socket.createServerWrap(SocketType.TCP, port, maxClients);
	}
	//
	public static inline function isError(skt:TcpWrapSocket) {
		return (cast skt) < 0;
	}
	
	/**
	 * Attempts to connect to the given address.
	 * @param	url  IP to connect to
	 * @param	port Port to use
	 * @return       Connection status. Below zero on failure.
	 */
	public inline function connect(url:String, port:Int):Int {
		return this.connectWrap(url, port);
	}
	
	/**
	 * Sends a packet to this socket.
	 * @param	buffer Buffer containing the packet
	 * @param	size   Number of bytes (starting from beginning) to send
	 * @return	       Number of bytes sent. Below zero on failure.
	 */
	public inline function send(buffer:Buffer, size:Int):Int {
		return this.sendTcpWrap(buffer, size);
	}
}
