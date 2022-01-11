package gml;

/**
 * ...
 * @author YellowAfterlife
 */
@:std @:native("date") @:snakeCase
extern class NativeDate {
	public static inline var epochStart:NativeDate = cast 25569;
	public static inline var msPerDay:Float = 1000 * 60 * 60 * 24;
	//
	@:native("create_datetime") function new(y:Int, n:Int, d:Int, h:Int, m:Int, s:Int);
	static function currentDatetime():NativeDate;
	//
	public var day(get, never):Int;
	public var month(get, never):Int;
	public var year(get, never):Int;
	public var hour(get, never):Int;
	public var minute(get, never):Int;
	public var second(get, never):Int;
	public var weekday(get, never):Int;
	//
	private function get_day():Int;
	private function get_month():Int;
	private function get_year():Int;
	private function get_hour():Int;
	private function get_minute():Int;
	private function get_second():Int;
	private function get_weekday():Int;
	//
	function datetimeString():String;
	//
	function incSecond(amt:Int):NativeDate;
	function incMinute(amt:Int):NativeDate;
	function incHour(amt:Int):NativeDate;
	function incDay(amt:Int):NativeDate;
	function incMonth(amt:Int):NativeDate;
	function incYear(amt:Int):NativeDate;
	inline function incMS(amt:Float):NativeDate {
		return ofRawTime(asRawTime() + amt / (1000. * 60 * 60 * 24));
	}
	//
	function secondSpan(till:NativeDate):Float;
	//
	static function getTimezone():NativeTimezone;
	static function setTimezone(tz:NativeTimezone):Void;
	public static inline function utcOp(fn:Void->Void):Void {
		var tz = getTimezone();
		setTimezone(NativeTimezone.UTC);
		fn();
		setTimezone(tz);
	}
	//
	/** This returns a GM/Delphi specific timestamp that measures in days from ~1900 */
	public inline function asRawTime():Float return cast this;
	/** Casts from a GM/Delphi specific timestamp to NativeDate */
	public static inline function ofRawTime(t:Float):NativeDate return cast t;
	
	/** Returns a timestamp with microsecond precision */
	@:expose("get_timer") static function getTimer():Float;
	
	/** Microseconds since last frame */
	@:expose("delta_time") static var deltaTime:Float;
}

@:std @:native("timezone") @:snakeCase
private extern class NativeTimezone {
	static var Local:NativeTimezone;
	static var UTC:NativeTimezone;
}