package gml.gpu;

/**
 * ...
 * @author YellowAfterlife
 */
@:std @:snakeCase @:native("matrix")
extern class Matrix {
	
	@:native("build_identity") public function new():Void;
	
	public static function build(
		x:Float, y:Float, z:Float,
		xrot:Float, yrot:Float, zrot:Float,
		xscale:Float, yscale:Float, zscale:Float
	):Matrix;
	
	public static function buildLookat(
		x1:Float, y1:Float, z1:Float,
		x2:Float, y2:Float, z2:Float,
		xup:Float, yup:Float, zup:Float
	):Matrix;
	
	@:expose("matrix_build_projection_ortho")
	public static function buildOrtho(w:Float, h:Float, znear:Float, zfar:Float):Matrix;
	
	@:expose("matrix_build_projection_perspective")
	public static function buildPerspective(w:Float, h:Float, znear:Float, zfar:Float):Matrix;
	
	@:expose("matrix_build_projection_perspective_fov")
	public static function buildPerspectiveFov(fovY:Float, aspect:Float, znear:Float, zfar:Float):Matrix;
	
	public static function transformVertex(x:Float, y:Float, z:Float):Array<Float>;
	
	public static function get(type:MatrixType):Matrix;
	public static function set(type:MatrixType, mtx:Matrix):Void;
	
	public function multiply(mtx:Matrix):Matrix;
}
