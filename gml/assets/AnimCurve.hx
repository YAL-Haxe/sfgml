package gml.assets;
import gml.assets.Asset;
import haxe.extern.EitherType;

@:native("animcurve") @:final @:std
extern class AnimCurve extends Asset {
	var name(get, never):String;
	private inline function get_name():String {
		return getStruct().name;
	}
	
	static function create():AnimCurveStruct;
	static function destroy(struct:AnimCurveStruct):Void;
	
	static inline function fromIndex(ind:Int):AnimCurve {
		return cast ind;
	}
	
	@:native("exists") static function isValid(q:EitherType<AnimCurve, AnimCurveStruct>):Bool;
	
	@:native("get") function getStruct():AnimCurveStruct;
}

@:std @:gml.struct @:gml.flat_new
extern class AnimCurveStruct {
	var name:String;
	var channels:Array<AnimCurveChannel>;
	
	@:expose("animcurve_create") function new();
	
	inline function destroy():Void {
		AnimCurve.destroy(this);
	}
}

@:std @:gml.struct @:gml.flat_new
extern class AnimCurveChannel {
	var name:String;
	var type:AnimCurveType;
	var iterations:Int;
	var points:Array<AnimCurvePoint>;
	
	@:expose("animcurve_channel_new") function new();
	
	@:expose("animcurve_channel_evaluate")
	private static function __evaluate(ch:AnimCurveChannel, posX:Float):Float;
	
	inline function evaluate(posX:Float):Float {
		return __evaluate(this, posX);
	}
}

@:std @:gml.struct @:gml.flat_new
extern class AnimCurvePoint {
	var posx:Float;
	var value:Float;
	
	@:expose("animcurve_point_new") function new();
}

@:native("animcurvetype") @:std @:snakeCase
extern enum abstract AnimCurveType(Int) {
	var Linear;
	@:native("catmullrom") var CatmullRom;
	var Bezier;
}
