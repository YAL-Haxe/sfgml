package gml.assets;
import gml.assets.Asset;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("object") @:final
extern class Object extends Asset {
	static inline var defValue:Object = cast -1;
	//
	@:native("exists") static function isValid(q:Object):Bool;
	static inline function fromIndex(i:Int):Object return cast i;
	
	var index(get, never):Int;
	private inline function get_index():Int return cast this;
	
	var name(get, never):String;
	private function get_name():String;
	
	var parent(get, never):Object;
	private function get_parent():Object;
	
	/** returns whether this object is a child of given object */
	@:native("is_ancestor") public function isChildOf(par:Object):Bool;
	
	
	/** default sprite for newly created instances of this type */
	var sprite(get, set):Sprite;
	private function get_sprite():Sprite;
	@:native("set_sprite") private function set_sprite_raw(q:Sprite):Void;
	private inline function set_sprite(q:Sprite):Sprite { set_sprite_raw(q); return q; }
	
	/** default collision mask for newly created instances of this type */
	var mask(get, set):Sprite;
	private function get_mask():Sprite;
	@:native("set_mask") private function set_mask_raw(q:Sprite):Void;
	private inline function set_mask(q:Sprite):Sprite { set_mask_raw(q); return q; }
	
	
	#if (sfgml_next)
	/** creates an instance of this object type at the given depth */
	public inline function createAtDepth<T:Instance>(x:Float, y:Float, depth:Float, ?c:Class<T>):T {
		return Lib.raw("instance_create_depth")(x, y, depth, this);
	}
	
	/** creates an instance of this object type at the given layer */
	public inline function createAtLayer<T:Instance>(x:Float, y:Float, layer:gml.layers.LayerID, ?c:Class<T>):T {
		return Lib.raw("instance_create_layer")(x, y, layer, this);
	}
	
	#else
	
	/** default depth for newly created instances of this type */
	var depth(get, set):Float;
	private function get_depth():Float;
	@:native("set_depth") private function set_depth_raw(q:Float):Void;
	private inline function set_depth(q:Float):Float { set_depth_raw(q); return q; }
	
	/** creates an instance of this object type at given coordinates */
	public inline function createAt<T:Instance>(x:Float, y:Float, ?c:Class<T>):T {
		return Lib.raw("instance_create")(x, y, this);
	}
	#end
}
