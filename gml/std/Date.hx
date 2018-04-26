package;

/**
 * ...
 * @author YellowAfterlife
 */
abstract Date(DateImpl) from DateImpl {
	public inline function new(y:Int, n:Int, d:Int, h:Int, m:Int, s:Int) {
		this = new DateImpl(y, n + 1, d, h, m, s);
	}
	//
	public inline function getFullYear():Int return this.get_year();
	public inline function getMonth():Int return this.get_month() - 1;
	public inline function getDay():Int return this.get_day();
	//
	public inline function getHours():Int return this.get_hour();
	public inline function getMinutes():Int return this.get_minute();
	public inline function getSeconds():Int return this.get_second();
	//
	public inline function toString():String return this.datetime_string();
	//
	public static inline function now():Date return DateImpl.current_datetime();
}
@:native("date") private extern class DateImpl {
	@:native("create_datetime") function new(y:Int, n:Int, d:Int, h:Int, m:Int, s:Int);
	function get_day():Int;
	function get_month():Int;
	function get_year():Int;
	function get_hour():Int;
	function get_minute():Int;
	function get_second():Int;
	function datetime_string():String;
	static function current_datetime():DateImpl;
}
