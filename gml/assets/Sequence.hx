package gml.assets;
import gml.gpu.Texture;

/**
	
**/
@:gml.struct extern class Sequence {
	public var name:String;
	// TODO https://manual.gamemaker.io/monthly/en/index.htm#t=GameMaker_Language%2FGML_Reference%2FAsset_Management%2FSequences%2FSequence_Structs%2FThe_Sequence_Object_Struct.htm
}
@:native("sequence")
extern class SequenceAsset extends Asset {
	public static function get(seqAsset:SequenceAsset):Sequence;
	
	public static inline function fromIndex(i:Int):SequenceAsset {
		return cast i;
	}
	
	@:native("exists")
	public static function isValid(seqAsset:SequenceAsset):Bool;
	
	public var struct(get, never):Sequence;
	private inline function get_struct():Sequence {
		return get(this);
	}
}