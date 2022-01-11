package;
import gml.NativeDate;

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
