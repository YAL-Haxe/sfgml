package gml.io;
/**
 * ...
 * @author YellowAfterlife
 */
@:std @:enum abstract BufferType(Int) from Int to Int {
	public static function sizeof(type:BufferType):Int {
		return Buffer.sizeof(type);
	}
	//
	var u8:BufferType = 1;
	var s8:BufferType = 2;
	var u16:BufferType = 3;
	var s16:BufferType = 4;
	var u32:BufferType = 5;
	var s32:BufferType = 6;
	var f16:BufferType = 7;
	var f32:BufferType = 8;
	var f64:BufferType = 9;
	var bool:BufferType = 10;
	var string:BufferType = 11;
	/** is actually s64 */
	var u64:BufferType = 12;
	var text:BufferType = 13;
}
