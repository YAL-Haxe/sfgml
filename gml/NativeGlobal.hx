package gml;

/**
 * Cleaner than passing Lib.global to variable_instance_* functions.
 * @author YellowAfterlife
 */
@:std
extern class NativeGlobal {
	@:expose("variable_global_get")
	@:pure static function getField(fd:String):Dynamic;
	
	@:expose("variable_global_exists")
	@:pure static function hasField(fd:String):Dynamic;
	
	@:expose("variable_global_set")
	static function setField(fd:String, val:Dynamic):Void;
	
	@:pure static inline function getFieldNames():Array<String> {
		return getFieldNamesRaw(Lib.global);
	}
	@:expose("variable_instance_get_names")
	private static function getFieldNamesRaw(obj:Dynamic):Array<String>;
	
	@:pure static inline function getFieldCount():Int {
		return getFieldCountRaw(Lib.global);
	}
	@:expose("variable_instance_get_count")
	private static function getFieldCountRaw(obj:Dynamic):Int;
}