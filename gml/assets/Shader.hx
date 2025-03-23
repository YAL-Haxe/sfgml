package gml.assets;

@:native("shader") @:final @:std
extern class Shader extends Asset {
	static inline var defValue:Sprite = cast -1;
	//
	static inline function fromIndex(i:Int):Shader return cast i;
	
	public static inline function isValid(sh:Shader):Bool {
		// aha, no shader_exists()
		return ShaderHacks.isValid(sh);
	}
	//{
	/** GMS2 only */
	var name(get, never):String;
	private function get_name():String;
	
	var index(get, never):Int;
	private inline function get_index():Int return cast this;
	//}
}
@:std class ShaderHacks {
	public static function isValid(sh:Shader) {
		try {
			var name = sh.name;
			return name != null && name != "" && name.charCodeAt(0) != "<".code;
		} catch (x:Dynamic) {
			return false;
		}
	}
}