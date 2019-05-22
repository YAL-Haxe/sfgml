package gml.events;

/**
 * ...
 * @author YellowAfterlife
 */
@:std extern class AsyncEvent {
	@:expose("async_load") static var map:Map<String, Dynamic>;
	static var http(get, never):HTTPEvent;
	private static inline function get_http():HTTPEvent {
		return cast map;
	}
}
