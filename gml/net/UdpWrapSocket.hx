package gml.net;
import gml.io.Buffer;

/**
 * ...
 * @author YellowAfterlife
 */
@:forward(destroy)
abstract UdpWrapSocket(Socket) {
	public static var defValue:UdpWrapSocket = cast -1;
	//
	public inline function new() {
		this = new Socket.createClient(SocketType.UDP);
	}
	public static inline function createAt(port:Int):UdpWrapSocket {
		return cast Socket.createClientAt(SocketType.UDP, port);
	}
	public static inline function createServer(port:Int, maxClients:Int):UdpWrapSocket {
		return cast Socket.createServerWrap(SocketType.UDP, port, maxClients);
	}
	//
	public static inline function isError(skt:UdpWrapSocket) {
		return (cast skt) < 0;
	}
	
	/**
	 * Sends a packet via this socket.
	 * @param	url    IP to send to
	 * @param	port   Port to send to
	 * @param	buffer Buffer containing the packet
	 * @param	size   Number of bytes (starting from beginning) to send
	 * @return	       Number of bytes sent. Below zero on failure.
	 */
	public inline function send(url:String, port:Int, buffer:Buffer, size:Int):Int {
		return this.sendUdpWrap(url, port, buffer, size);
	}
}
