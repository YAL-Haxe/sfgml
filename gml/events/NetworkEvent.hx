package gml.events;
import gml.Lib.raw as raw;
import gml.net.Socket;
import gml.io.BufferReader;
import gml.ds.HashTable;

/**
 * ...
 * @author YellowAfterlife
 */
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

enum abstract NetworkEventType(Int) from Int to Int {
	var CONNECT = 1;
	var DISCONNECT = 2;
	var DATA = 3;
	var NBCONNECT = 4;
}
/*abstract NetworkEventType(Int) {
	public static inline var CONNECT:NetworkEventType = cast 1;
	public static inline var DISCONNECT:NetworkEventType = cast 2;
	public static inline var DATA:NetworkEventType = cast 3;
	public static inline var NBCONNECT:NetworkEventType = cast 4;
}*/
