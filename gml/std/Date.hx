package;

/**
 * ...
 * @author YellowAfterlife
 */
@:coreApi @:std class Date {
	private var date:NativeDate;
	
	public function new(year:Int, month:Int, day:Int, hour:Int, min:Int, sec:Int) {
		date = new NativeDate(year, month + 1, day, hour, min, sec);
	}
	private static inline function createEmpty():Date {
		return new Date(2000, 0, 1, 0, 0, 0);
	}
	public static function now():Date {
		var d = createEmpty();
		d.date = NativeDate.currentDatetime();
		return d;
	}
	
	public function getTime():Float {
		return (date.asRawTime() - NativeDate.epochStart.asRawTime()) * NativeDate.msPerDay;
	}
	public static function fromTime(t:Float):Date {
		var d = createEmpty();
		d.date = NativeDate.epochStart.incMS(t);
		return d;
	}
	
	public inline function getHours():Int {
		return date.hour;
	}

	public inline function getMinutes():Int {
		return date.minute;
	}

	public inline function getSeconds():Int {
		return date.second;
	}

	public inline function getFullYear():Int {
		return date.year;
	}

	public inline function getMonth():Int {
		return date.month - 1;
	}

	public inline function getDate():Int {
		return date.day;
	}
	
	public inline function getDay():Int {
		return date.weekday;
	}
	
	public inline function toString():String {
		return date.datetimeString();
	}
	public static function fromString(s:String):Date {
		var args:Array<String>, d:Date, nd:NativeDate;
		switch (s.length) {
			case 8: {
				NativeDate.utcOp(function() {
					nd = NativeDate.epochStart;
					nd = nd.incHour(Std.parseInt(s.substring(0, 2)));
					nd = nd.incMinute(Std.parseInt(s.substring(3, 2)));
					nd = nd.incSecond(Std.parseInt(s.substring(5, 2)));
				});
				d = createEmpty();
				d.date = nd;
				return d;
			};
			default: throw "Invalid date format : " + s;
		}
	}
	
	//{
	public function getTimezoneOffset():Int {
		throw "not implemented";
	}
	
	public inline function getUTCHours():Int {
		throw "not implemented";
	}

	public inline function getUTCMinutes():Int {
		throw "not implemented";
	}

	public inline function getUTCSeconds():Int {
		throw "not implemented";
	}

	public inline function getUTCFullYear():Int {
		throw "not implemented";
	}

	public inline function getUTCMonth():Int {
		throw "not implemented";
	}

	public inline function getUTCDate():Int {
		throw "not implemented";
	}

	public inline function getUTCDay():Int {
		throw "not implemented";
	}
	//}
}

@:std @:native("date") @:snakeCase
private extern class NativeDate {
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
}

@:std @:native("timezone") @:snakeCase
private extern class NativeTimezone {
	static var Local:NativeTimezone;
	static var UTC:NativeTimezone;
}