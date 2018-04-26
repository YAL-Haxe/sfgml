package;
import SfTools.raw;
import gml.Lib;
import gml.NativeArray;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("haxe_sys") class Sys {
	public static inline function println(v:Dynamic):Void {
		raw("show_debug_message")(v);
	}
	public static function args():Array<String> {
		var argc = raw("parameter_count")() - 1;
		var argv = NativeArray.create(argc);
		for (i in 0 ... argc) {
			argv[i] = raw("parameter_string")(i + 1);
		}
		return argv;
	}
	public static inline function getEnv(s:String):String {
		return raw("environment_get_variable")(s);
	}
	public static function sleep(sec:Float):Void {
		var t = Lib.getTimer() + sec * 1000;
		while (Lib.getTimer() < t) { };
	}
	public static inline function getCwd():String {
		return "";
	}
	public static function systemName():String {
		return switch (raw("os_type")) {
			case 0: "Windows";
			case 1: "Mac";
			case 3: "iOS";
			case 4: "Android";
			case 6: "Linux";
			case 7: "WinPhone";
			case 8: "Tizen";
			case 12: "PSVita";
			case 14: "PlayStation4";
			case 15: "XBoxOne";
			case 16: "PlayStation3";
			case 17: "XBox360";
			case 18: "UWP";
			case 19: "tvOS";
			default: "Unknown";
		}
	}
	public static inline function exit(code:Int):Void {
		raw("game_end")();
	}
	public static inline function time():Float {
		return raw("get_timer")() / 1000000;
	}
	public static inline function programPath():String {
		return raw("parameter_string")(0);
	}
}
