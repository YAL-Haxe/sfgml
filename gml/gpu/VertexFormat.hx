package gml.gpu;

/**
 * ...
 * @author YellowAfterlife
 */
@:forwardStatics @:forward @:native("vertex_format_hx")
abstract VertexFormat(VertexFormatImpl) from VertexFormatImpl to VertexFormatImpl {
	@:native("create") public function new(data:SfRest<VertexFormatData>) {
		VertexFormatImpl.begin();
		for (item in data) switch (item) {
			case Color: VertexFormatImpl.addColor();
			case Pos2d: VertexFormatImpl.addPosition();
			case Pos3d: VertexFormatImpl.addPosition3d();
			case TexCoord: VertexFormatImpl.addTexCoord();
			case Normal: VertexFormatImpl.addNormal();
			case Custom(t, u): VertexFormatImpl.addCustom(t, u);
		}
		this = VertexFormatImpl.end();
	}
	public static inline function end():VertexFormat {
		return VertexFormatImpl.end();
	}
}
@:native("vertex_format") @:std @:snakeCase
private extern class VertexFormatImpl {
	public static inline var defValue:VertexFormat = cast -1;
	
	@:native("delete") function destroy():Void;
	static function begin():Void;
	static function end():VertexFormatImpl;
	
	//
	static function addColor():Void;
	static function addPosition():Void;
	@:native("add_position_3d") static function addPosition3d():Void;
	@:native("add_texcoord") static function addTexCoord():Void;
	static function addNormal():Void;
	static function addCustom(type:VertexFormatType, usage:VertexFormatUsage):Void;
}
