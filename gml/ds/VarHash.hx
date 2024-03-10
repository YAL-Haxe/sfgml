package gml.ds;

/**
 * ...
 * @author YellowAfterlife
 */
extern class VarHash {
	@:expose("variable_get_hash")
	public function new(name:String):Void;
	
	@:expose("struct_get_from_hash")
	public static function get(from:Dynamic, hash:VarHash):Dynamic;
	
	@:expose("struct_set_from_hash")
	public static function set(to:Dynamic, hash:VarHash, value:Dynamic):Void;
	
	public inline function readFrom(from:Dynamic):Dynamic {
		return get(from, this);
	}
	public inline function writeTo(to:Dynamic, value:Dynamic):Void {
		set(to, this, value);
	}
	//
	public inline function toInt():Int {
		return cast this;
	}
	public static inline function fromInt(id:Int):VarHash {
		return cast id;
	}
}