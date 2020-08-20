package gml.assets;

@:native("shader") @:final @:std
extern class Shader extends Asset {
	static inline var defValue:Sprite = cast -1;
	//
	static inline function fromIndex(i:Int):Shader return cast i;
	
	public static inline function isValid(sh:Shader):Bool {
		// aha, mhm
		return sh.name.charCodeAt(0) != "<".code;
	}
	//{
	/** GMS2 only */
	var name(get, never):String;
	private function get_name():String;
	
	var index(get, never):Int;
	private inline function get_index():Int return cast this;
	//}
}
