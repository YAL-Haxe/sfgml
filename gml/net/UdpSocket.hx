package gml.net;
import gml.io.Buffer;

/**
 * ...
 * @author YellowAfterlife
 */
@:std @:docName("network_socket")
@:forward(destroy)
abstract UdpSocket(Socket) {
	public static var defValue:UdpSocket = cast -1;
	//
	public inline function new() {
		this = Socket.createClient(SocketType.UDP);
	}
	public static inline function createAt(port:Int):UdpSocket {
		return cast Socket.createClientAt(SocketType.UDP, port);
	}
	public static inline function createServer(port:Int, maxClients:Int):UdpSocket {
		return cast Socket.createServer(SocketType.UDP, port, maxClients);
	}
	//
	public static inline function isError(skt:UdpSocket) {
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
		return this.sendUdp(url, port, buffer, size);
	}
}
