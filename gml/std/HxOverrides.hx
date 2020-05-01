package;

/**
 * ...
 * @author YellowAfterlife
 */
@:noDoc
class HxOverrides {
	static function dateStr( date :Date ) : String {
		return date.toString();
		/*var m = date.getMonth() + 1;
		var d = date.getDate();
		var h = date.getHours();
		var mi = date.getMinutes();
		var s = date.getSeconds();
		return date.getFullYear()
			+"-"+(if( m < 10 ) "0"+m else ""+m)
			+"-"+(if( d < 10 ) "0"+d else ""+d)
			+" "+(if( h < 10 ) "0"+h else ""+h)
			+":"+(if( mi < 10 ) "0"+mi else ""+mi)
			+":"+(if( s < 10 ) "0"+s else ""+s);*/
	}
	
	static inline function now():Float {
		return gml.Lib.currentTime;
	}

	/*static function strDate( s : String ) : Date {
		switch( s.length ) {
		case 8: // hh:mm:ss
			var k = s.split(":");
			var d : Date = untyped __new__(Date);
			untyped d["setTime"](0);
			untyped d["setUTCHours"](k[0]);
			untyped d["setUTCMinutes"](k[1]);
			untyped d["setUTCSeconds"](k[2]);
			return d;
		case 10: // YYYY-MM-DD
			var k = s.split("-");
			return new Date(cast k[0],cast untyped k[1] - 1,cast k[2],0,0,0);
		case 19: // YYYY-MM-DD hh:mm:ss
			var k = s.split(" ");
			var y = k[0].split("-");
			var t = k[1].split(":");
			return new Date(cast y[0],cast untyped y[1] - 1,cast y[2],cast t[0],cast t[1],cast t[2]);
		default:
			throw "Invalid date format : " + s;
		}
	}*/

	@:pure static inline function cca( s : String, index : Int ) : Null<Int> {
		return s.charCodeAt(index);
	}

	@:pure static inline function substr( s : String, pos : Int, ?len : Int ) : String {
		return s.substr(pos, len);
	}

	@:pure static function indexOf<T>( a : Array<T>, obj : T, i : Int) {
		var len = a.length;
		if (i < 0) {
			i += len;
			if (i < 0) i = 0;
		}
		while (i < len)
		{
			if (untyped __js__("a[i] === obj"))
				return i;
			i++;
		}
		return -1;
	}

	@:pure
	static function lastIndexOf<T>( a : Array<T>, obj : T, i : Int) {
		var len = a.length;
		if (i >= len)
			i = len - 1;
		else if (i < 0)
			i += len;
		while (i >= 0)
		{
			if (untyped __js__("a[i] === obj"))
				return i;
			i--;
		}
		return -1;
	}

	static function remove<T>( a : Array<T>, obj : T ) {
		var i = a.indexOf(obj);
		if( i == -1 ) return false;
		a.splice(i,1);
		return true;
	}

	@:pure
	static function iter<T>( a : Array<T> ) : Iterator<T> untyped {
		return null;
	}

	static function __init__() untyped {
		
	}
}
