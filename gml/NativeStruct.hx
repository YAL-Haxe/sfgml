package gml;

/**
 * v2.3 introduced structs and some Reflection-like functions for them.
 * @author YellowAfterlife
 */
@:std extern class NativeStruct {
	@:expose("variable_struct_get")
	@:pure static function getField(obj:Dynamic, fd:String):Dynamic;
	
	@:expose("variable_struct_get_names")
	@:pure static function getFieldNames(obj:Dynamic):Array<String>;
	
	@:expose("variable_struct_names_count")
	@:pure static function getFieldCount(obj:Dynamic):Int;
	
	@:expose("variable_struct_exists")
	@:pure static function hasField(obj:Dynamic, fd:String):Dynamic;
	
	@:expose("variable_struct_set")
	static function setField(obj:Dynamic, fd:String, val:Dynamic):Void;
	
	/**
	 * Returns the name of constructor function for the given struct object.
	 * Can also return:
	 * "instance": when passed an instance reference (via `self`)
	 * "function": when passed a method-value from `method` call (see gml.NativeFunction)
	 * undefined: anything else
	 */
	@:expose("instanceof")
	static function instanceOf(obj:Dynamic):String;
}