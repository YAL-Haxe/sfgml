package gml.events;
import gml.Lib.raw as raw;
import gml.net.Socket;
import gml.io.BufferReader;
import gml.io.Buffer;
import gml.ds.HashTable;

/**
 * ...
 * @author YellowAfterlife
 */
#if !sfgml_async_legacy
@:std @:dsMap
typedef NetworkEvent = {
	var type:NetworkEventType;
	
	/** Sender socket in Data event, receiver otherwise */
	var id:Socket;
	
	/** IP address of associated socket  */
	var ip:String;
	
	/** Port of associated socket */
	var port:Int;
	
	/** In Connect/Disconnect this holds the [dis]connecting socket */
	?var socket:Socket;
	
	/** In NonBlockingConnect this indicates whether connection succeeded */
	?var succeeded:Bool;
	
	/** In Data this holds the received bytes */
	?var buffer:Buffer;
	
	/** In Data this holds the number of received bytes */
	?var size:Int;
}

@:std @:native("network_type")
extern enum abstract NetworkEventType(Int) {
	var Connect;
	var Disconnect;
	var Data;
	
	/**
	 * Triggered client-side if connection is non-blocking
	 * @see gml.net.Socket.config
	 */
	var NonBlockingConnect;
}
#else
@:final class NetworkEvent {
	public static var map(get, never):HashTable<String, Dynamic>;
	private static inline function get_map() return raw("async_load");
	//
	public static var type(get, never):NetworkEventType;
	private static inline function get_type() return map.get("type");
	/// Sender socket in DATA event, receiver otherwise.
	public static var target(get, never):Socket;
	private static inline function get_target() return map.get("id");
	///
	public static var ip(get, never):String;
	private static inline function get_ip():String return map.get("ip");
	///
	public static var port(get, never):Int;
	private static inline function get_port():Int return map.get("port");
	/// In CONNECT/DISCONNECT event this holds the [dis]connecting socket.
	public static var socket(get, never):Socket;
	private static inline function get_socket() return map.get("socket");
	/// In NBCONNECT this indicates whether the connection succeeded.
	public static var succeeded(get, never):Bool;
	private static inline function get_succeeded() return map.get("succeeded");
	/// In DATA event this holds the buffer with received information.
	public static var buffer(get, never):BufferReader;
	private static inline function get_buffer() return map.get("buffer");
	/// In DATA event this holds the number of bytes received
	public static var size(get, never):Int;
	private static inline function get_size():Int return map.get("size");
}

@:std @:native("network_type")
extern enum abstract NetworkEventType(Int) from Int to Int {
	@:native("connect") var CONNECT;
	@:native("disconnect") var DISCONNECT;
	@:native("data") var DATA;
	@:native("non_blocking_connect")var NBCONNECT;
}
#end