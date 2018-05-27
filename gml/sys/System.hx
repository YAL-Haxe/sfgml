package gml.sys;

/**
 * ...
 * @author YellowAfterlife
 */
@:std extern class System {
	@:expose("os_type") static var type:SystemType;
	@:expose("os_browser") static var browser:BrowserType;
	public static var isBrowser(get, never):Bool;
	private static inline function get_isBrowser():Bool {
		return browser != None;
	}
}
