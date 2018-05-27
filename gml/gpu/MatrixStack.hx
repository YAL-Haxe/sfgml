package gml.gpu;

/**
 * ...
 * @author YellowAfterlife
 */
@:std @:snakeCase @:native("matrix_stack")
extern class MatrixStack {
	
	public static function isEmpty():Bool;
	
	public static function clear():Void;
	
	public static function set(mtx:Matrix):Void;
	
	public static function push(mtx:Matrix):Void;
	
	public static function pop():Matrix;
	
	public static function top():Matrix;
	
}
