package gml.net;
import gml.io.Buffer;
import gml.Lib.raw as raw;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("network")
extern class Socket {
	//
	public static inline var defValue:Socket = cast -1;
	public static inline function isValid(skt:Socket):Bool {
		return (cast skt) >= 0;
	}
	//
	function destroy():Void;
	//{ Constructor group
	@:native("create_socket")
	static function createClient(type:SocketType):Socket;
	
	@:native("create_socket_ext")
	static function createClientAt(type:SocketType, port:Int):Socket;
	
	@:native("create_server_raw")
	static function createServer(type:SocketType, port:Int, maxClients:Int):Socket;
	
	@:native("create_server")
	static function createServerWrap(type:SocketType, port:Int, maxClients:Int):Socket;
	//}
	
	//{ Connection group
	@:native("connect_raw")
	function connect(url:String, port:Int):Int;
	@:native("connect")
	function connectWrap(url:String, port:Int):Int;
	//}
	
	//{ Data group
	/// Sends a buffer to this socket.
	@:native("send_raw")
	function sendTcp(buffer:Buffer, size:Int):Int;
	
	/// Sends a buffer to this socket.
	@:native("send_packet")
	function sendTcpWrap(buffer:Buffer, size:Int):Int;
	
	/// Sends a buffer using this socket.
	@:native("send_udp_raw")
	function sendUdp(url:String, port:Int, buffer:Buffer, size:Int):Int;
	
	/// Sends a buffer using this socket.
	@:native("send_udp")
	function sendUdpWrap(url:String, port:Int, buffer:Buffer, size:Int):Int;
	//}
	
	//{ Config group
	@:native("set_config")
	static function config(conf:Int, value:Dynamic):Void;
	/** Sets connection timeout, in milliseconds */
	static inline function confConnectTimeout(ms:Int):Void {
		config(raw("network_config_connect_timeout"), ms);
	}
	/** Enables non-blocking connections */
	static inline function confNonBlockingConnect(enable:Bool):Void {
		config(raw("network_config_use_non_blocking_socket"), enable);
	}
	//}
}
