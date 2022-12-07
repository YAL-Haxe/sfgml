package gml;
import gml.assets.*;
import gml.ds.Color;
import gml.gpu.PrimitiveKind;
import gml.gpu.TextAlign;
import gml.gpu.Texture;

@:std @:native("draw") @:snakeCase
extern class Draw {
	//
	static var color(get, set):Color;
	private static function get_color():Color;
	private static function set_color(c:Color):Color;
	
	//
	static var alpha(get, set):Float;
	private static function get_alpha():Float;
	private static function set_alpha(f:Float):Float;
	
	//
	static function clear(c:Color):Void;
	@:native("clear_alpha") static function clearAlpha(c:Color, a:Float):Void;
	
	//
	static function circle(x:Float, y:Float, r:Float, outline:Bool):Void;
	static function circleColor(x:Float, y:Float, r:Float, c1:Color, c2:Color, outline:Bool):Void;
	
	//
	static function ellipse(x1:Float, y1:Float, x2:Float, y2:Float, outline:Bool):Void;
	static function ellipseColor(x1:Float, y1:Float, x2:Float, y2:Float, c1:Color, c2:Color, outline:Bool):Void;
	
	//
	static function line(x1:Float, y1:Float, x2:Float, y2:Float):Void;
	static function lineWidth(x1:Float, y1:Float, x2:Float, y2:Float, w:Float):Void;
	static function lineColor(x1:Float, y1:Float, x2:Float, y2:Float, c1:Color, c2:Color):Void;
	@:native("line_width_color") static function lineExt(x1:Float, y1:Float, x2:Float, y2:Float, w:Float, c1:Color, c2:Color):Void;
	
	//
	static function point(x:Float, y:Float):Void;
	static function pointColor(x:Float, y:Float, c:Color):Void;
	
	//
	static function rectangle(x1:Float, y1:Float, x2:Float, y2:Float, outline:Bool):Void;
	static function rectangleColor(x1:Float, y1:Float, x2:Float, y2:Float, c1:Color, c2:Color, c3:Color, c4:Color, outline:Bool):Void;
	
	//
	static function roundrect(x1:Float, y1:Float, x2:Float, y2:Float, outline:Bool):Void;
	static function roundrectColor(x1:Float, y1:Float, x2:Float, y2:Float, c1:Color, c2:Color, outline:Bool):Void;
	static function roundrectExt(x1:Float, y1:Float, x2:Float, y2:Float, xrad:Float, yrad:Float, outline:Bool):Void;
	static function roundrectColorExt(x1:Float, y1:Float, x2:Float, y2:Float, xrad:Float, yrad:Float, c1:Color, c2:Color, outline:Bool):Void;
	
	//
	static function text(x:Float, y:Float, s:String):Void;
	static function textColor(x:Float, y:Float, s:String, c1:Color, c2:Color, c3:Color, c4:Color, alpha:Float):Void;
	static function textExt(x:Float, y:Float, s:String, sep:Float, w:Float):Void;
	static function textExtColor(x:Float, y:Float, s:String, sep:Float, w:Float, c1:Color, c2:Color, c3:Color, c4:Color, alpha:Float):Void;
	static function textTransformed(x:Float, y:Float, s:String, xscale:Float, yscale:Float, angle:Float):Void;
	static function textTransformedColor(x:Float, y:Float, s:String, xscale:Float, yscale:Float, angle:Float, c1:Color, c2:Color, c3:Color, c4:Color, alpha:Float):Void;
	static function textExtTransformed(x:Float, y:Float, s:String, sep:Float, width:Float, xscale:Float, yscale:Float, angle:Float):Void;
	static function textExtTransformedColor(x:Float, y:Float, s:String, s:String, sep:Float, xscale:Float, yscale:Float, angle:Float, c1:Color, c2:Color, c3:Color, c4:Color, alpha:Float):Void;
	
	//
	static inline function setTextAlign(h:TextAlign, v:TextAlign):Void {
		setHAlign(h);
		setVAlign(v);
	}
	static function setHAlign(h:TextAlign):Void;
	static function setVAlign(v:TextAlign):Void;
	
	//
	@:expose("string_width") static function textWidth(s:String):Float;
	@:expose("string_width_ext") static function textWidthExt(s:String, sep:Float, w:Float):Float;
	@:expose("string_height") static function textHeight(s:String):Float;
	@:expose("string_height_ext") static function textHeightExt(s:String, sep:Float, w:Float):Float;
	
	//
	static function triangle(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, outline:Bool):Void;
	static function triangleColor(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, c1:Color, c2:Color, c3:Color, outline:Bool):Void;
	
	//
	static function primitiveBegin(kind:PrimitiveKind):Void;
	static function primitiveBeginTexture(kind:PrimitiveKind, tex:Texture):Void;
	static function primitiveEnd():Void;
	static function vertex(x:Float, y:Float):Void;
	static function vertexColor(x:Float, y:Float, c:Color, alpha:Float):Void;
	static function vertexTexture(x:Float, y:Float, tx:Float, ty:Float):Void;
	static function vertexTextureColor(x:Float, y:Float, tx:Float, ty:Float, c:Color, alpha:Float):Void;
}
