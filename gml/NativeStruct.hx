package gml;

/**
 * v2.3 introduced structs and some Reflection-like functions for them.
 * @author YellowAfterlife
 */
@:std extern class NativeStruct {
	@:expose("variable_struct_get")
	static function getField<T:{}>(obj:T, fd:String):Dynamic;
	
	@:expose("variable_struct_get_names")
	static function getFieldNames<T:{}>(obj:T):Array<String>;
	
	@:expose("variable_struct_exists")
	@:pure static function hasField<T:{}>(obj:T, fd:String):Dynamic;
	
	@:expose("variable_struct_set")
	static function setField<T:{}>(obj:T, fd:String, val:Dynamic):Void;
}