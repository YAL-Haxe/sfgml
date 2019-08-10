package gml.events;
import gml.ds.HashTable;

/**
 * ...
 * @author YellowAfterlife
 */
@:std extern class AsyncEvent {
	@:expose("async_load") static var map:HashTable<String, Dynamic>;
	static var http(get, never):HTTPEvent;
	private static inline function get_http():HTTPEvent {
		return cast map;
	}
	#if !sfgml_async_legacy
	static var network(get, never):NetworkEvent;
	private static inline function get_network():NetworkEvent {
		return cast map;
	}
	#end
}
