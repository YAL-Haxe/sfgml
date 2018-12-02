package gml.gpu;
import gml.ds.Color;
import gml.io.Buffer;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("vertex") @:std @:snakeCase
extern class VertexBuffer {
	
	public static inline var defValue:VertexBuffer = cast - 1;
	
	/** (in bytes) */
	var size(get, never):Int;
	@:native("get_buffer_size") private function get_size():Int;
	
	/** (in vertices) */
	var number(get, never):Int;
	private function get_number():Int;
	
	//
	@:native("create_buffer") function new():Void;
	@:native("create_buffer_ext") static function alloc(size:Int):VertexBuffer;
	@:native("create_buffer_from_buffer") static function fromBuffer(buf:Buffer, fmt:VertexFormat):Void;
	@:native("create_buffer_from_buffer_ext") static function fromBufferExt(buf:Buffer, fmt:VertexFormat, offset:Int, vertNumber:Int):Void;
	@:native("delete_buffer") function destroy():Void;
	
	//
	function begin(fmt:VertexFormat):Void;
	function end():Void;
	function freeze():Void;
	@:native("submit") private function submitImpl(kind:PrimitiveKind, texture:Texture):Void;
	inline function submit(kind:PrimitiveKind, texture:Texture = Texture.defValue):Void {
		submitImpl(kind, texture);
	}
	
	//
	function color(col:Color, alpha:Float):Void;
	@:native("position") function pos2d(x:Float, y:Float):Void;
	@:native("position_3d") function pos3d(x:Float, y:Float, z:Float):Void;
	function normal(x:Float, y:Float, z:Float):Void;
	function argb(val:Int):Void;
	function texcoord(u:Float, v:Float):Void;
	function float1(f:Float):Void;
	function float2(f1:Float, f2:Float):Void;
	function float3(f1:Float, f2:Float, f3:Float):Void;
	function float4(f1:Float, f2:Float, f3:Float, f4:Float):Void;
	function ubyte4(u1:Int, u2:Int, u3:Int, u4:Int):Void;
}
