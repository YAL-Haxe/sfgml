package gml.gpu;
import gml.assets.Font;
import gml.ds.Color;

/**
 * Note: getters for halign/valign/font/GMS1 blend modes
 * are only confirmed as planned for future updates.
 * @author YellowAfterlife
 */
@:native("") @:std extern class GPU {
	
	/** Color to be used for text and primitives */
	public static var color(get, set):Color;
	@:expose("draw_get_color") private static function get_color():Color;
	@:expose("draw_set_color") private static function set_color_raw(v:Color):Void;
	private static inline function set_color(c:Color):Color {
		set_color_raw(c);
		return c;
	}
	
	/** Alpha multiplier to be used for text, primitives, and images */
	public static var alpha(get, set):Float;
	@:expose("draw_get_alpha") private static function get_alpha():Float;
	@:expose("draw_set_alpha") private static function set_alpha_raw(a:Float):Void;
	private static inline function set_alpha(a:Float):Float {
		set_alpha_raw(a);
		return a;
	}
	
	/** Horizontal alignment for drawn text */
	public static var halign(get, set):TextAlign;
	@:expose("draw_get_halign") private static function get_halign():TextAlign;
	@:expose("draw_set_halign") private static function set_halign_raw(h:TextAlign):Void;
	private static inline function set_halign(h:TextAlign):TextAlign {
		set_halign_raw(h);
		return h;
	}
	
	/** Vertical alignment for drawn text */
	public static var valign(get, set):TextAlign;
	@:expose("draw_get_valign") private static function get_valign():TextAlign;
	@:expose("draw_set_valign") private static function set_valign_raw(v:TextAlign):Void;
	private static inline function set_valign(v:TextAlign):TextAlign {
		set_valign_raw(v);
		return v;
	}
	
	/** Font to be used for drawn text */
	public static var font(get, set):Font;
	@:expose("draw_get_font") private static function get_font():Font;
	@:expose("draw_set_font") private static function set_font_raw(q:Font):Void;
	private static inline function set_font(q:Font):Font {
		set_font_raw(q);
		return q;
	}
	
	@:expose("draw_clear") public static function clear(color:Color):Void;
	@:expose("draw_clear_alpha") public static function clearExt(color:Color, alpha:Float):Void;
	
	public static var blendSimple(get, set):BlendSimple;
	private static inline function get_blendSimple():BlendSimple {
		return getBlendSimple();
	}
	private static inline function set_blendSimple(mode:BlendSimple):BlendSimple {
		setBlendSimple(mode);
		return mode;
	}
	
	public static var blendMode(get, set):BlendModePair;
	private static inline function set_blendMode(pair:BlendModePair):BlendModePair {
		setBlendModePair(pair);
		return pair;
	}
	
	#if (sfgml_next)
	
	@:expose("gpu_set_blendmode")
	public static function setBlendSimple(m:BlendSimple):Void;
	
	@:expose("gpu_get_blendmode")
	public static function getBlendSimple():BlendSimple;
	
	@:expose("gpu_set_blendmode_ext")
	private static function setBlendModePair(pair:BlendModePair):Void;
	
	@:expose("gpu_set_blendmode_ext")
	public static function setBlendMode(src:BlendMode, dst:BlendMode):Void;
	
	@:expose("gpu_get_blendmode_src")
	public static function getBlendModeSrc():BlendMode;
	
	@:expose("gpu_get_blendmode_dest")
	public static function getBlendModeDest():BlendMode;
	
	#else
	
	@:expose("draw_set_blend_mode")
	public static function setBlendSimple(m:BlendSimple):Void;
	
	@:expose("draw_get_blend_mode")
	public static function getBlendSimple():BlendSimple;
	
	private static inline function setBlendModePair(pair:BlendModePair):Void {
		setBlendMode(pair.src, pair.dest);
	}
	
	@:expose("draw_set_blend_mode_ext")
	public static function setBlendMode(src:BlendMode, dst:BlendMode):Void;
	
	@:expose("draw_get_blend_mode_src")
	public static function getBlendModeSrc():BlendMode;
	
	@:expose("draw_get_blend_mode_dest")
	public static function getBlendModeDest():BlendMode;
	#end
}
@:nativeGen typedef BlendModePair = { src:BlendMode, dest:BlendMode };
