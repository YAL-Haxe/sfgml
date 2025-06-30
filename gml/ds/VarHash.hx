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
	
	@:expose("struct_exists_from_hash")
	public static function exists(struct:Dynamic, hash:VarHash):Bool;
	
	@:expose("struct_remove_from_hash")
	public static function remove(struct:Dynamic, hash:VarHash):Void;
	
	public inline function readFrom(from:Dynamic):Dynamic {
		return get(from, this);
	}
	public inline function writeTo(to:Dynamic, value:Dynamic):Void {
		set(to, this, value);
	}
	public inline function existsIn(struct:Dynamic){
		return exists(struct, this);
	}
	//
	public inline function toInt():Int {
		return cast this;
	}
	public static inline function fromInt(id:Int):VarHash {
		return cast id;
	}
}