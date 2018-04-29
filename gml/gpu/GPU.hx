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
	
	//{ Font
	
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
	//}
	
	//{ Blend modes
	
	public static var blendSimple(get, set):BlendSimple;
	private static inline function get_blendSimple():BlendSimple {
		return getBlendSimple();
	}
	private static inline function set_blendSimple(mode:BlendSimple):BlendSimple {
		setBlendSimple(mode);
		return mode;
	}
	
	public static var blendMode(get, set):BlendModePair;
	private static inline function get_blendMode():BlendModePair {
		return getBlendModePair();
	}
	private static inline function set_blendMode(pair:BlendModePair):BlendModePair {
		setBlendModePair(pair);
		return pair;
	}
	
	#if (sfgml_next) // blend mode implementations
	
	@:expose("gpu_set_blendmode")
	public static function setBlendSimple(m:BlendSimple):Void;
	
	@:expose("gpu_get_blendmode")
	public static function getBlendSimple():BlendSimple;
	
	@:expose("gpu_get_blendmode_ext")
	private static function getBlendModePair():BlendModePair;
	
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
	
	private static inline function getBlendModePair():BlendModePair {
		// returning directly types the result as TAnonymous instead of BMPair..?
		var q:BlendModePair = { src: getBlendModeSrc(), dest: getBlendModeDest() };
		return q;
	}
	
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
	
	#if (sfgml_next) // separated blend modes (GMS2 only)
	public static var blendModeSep(get, set):BlendModeSep;
	
	@:expose("gpu_get_blendmode_ext_sepalpha")
	private static function get_blendModeSep():BlendModeSep;
	
	@:expose("gpu_set_blendmode_ext_sepalpha")
	private static function setBlendModeSep_impl(sep:BlendModeSep):Void;
	
	private static inline function set_blendModeSep(m:BlendModeSep):BlendModeSep {
		setBlendModeSep_impl(m);
		return m;
	}
	
	@:expose("gpu_set_blendmode_ext_sepalpha")
	public static function setBlendModeSep(srcColor:BlendMode, destColor:BlendMode, srcAlpha:BlendMode, destAlpha:BlendMode):Void;
	#end
	
	//}
	
	//{ Alpha test
	public static var alphaTest(get, set):Bool;
	private static inline function set_alphaTest(z:Bool):Bool {
		set_alphaTest_impl(z);
		return z;
	}
	public static var alphaTestRef(get, set):Float;
	private static inline function set_alphaTestRef(f:Float):Float {
		set_alphaTestRef_impl(f);
		return f;
	}
	#if (sfgml_next)
	@:expose("gpu_get_alphatestenable") private static function get_alphaTest():Bool;
	@:expose("gpu_set_alphatestenable") private static function set_alphaTest_impl(z:Bool):Void;
	@:expose("gpu_get_alphatestref") private static function get_alphaTestRef():Float;
	@:expose("gpu_set_alphatestref") private static function set_alphaTestRef_impl(f:Float):Void;
	#else
	@:expose("draw_get_alpha_test") private static function get_alphaTest():Bool;
	@:expose("draw_set_alpha_test") private static function set_alphaTest_impl(z:Bool):Void;
	@:expose("draw_get_alpha_test_ref_value") private static function get_alphaTestRef():Float;
	@:expose("draw_set_alpha_test_ref_value") private static function set_alphaTestRef_impl(f:Float):Void;
	#end
	//}
	
	//{ Color write
	public static var colorWrite(get, set):ColorWrite;
	private static inline function set_colorWrite(c:ColorWrite):ColorWrite {
		set_colorWrite_impl(c);
		return c;
	}
	#if (sfgml_next)
	@:expose("gpu_get_colorwriteenable") private static function get_colorWrite():ColorWrite;
	@:expose("gpu_set_colorwriteenable") private static function set_colorWrite_impl(c:ColorWrite):Void;
	@:expose("gpu_set_colorwriteenable") public static function setColorWrite(r:Bool, g:Bool, b:Bool, a:Bool):Void;
	#else
	private static inline function get_colorWrite():ColorWrite {
		throw "GMS1 doesn't have a ColorWrite getter function";
	}
	private static inline function set_colorWrite_impl(c:ColorWrite):Void {
		setColorWrite(c.red, c.green, c.blue, c.alpha);
	}
	@:expose("draw_set_color_write_enable") public static function setColorWrite(r:Bool, g:Bool, b:Bool, a:Bool):Void;
	#end
	//}
	
	//{ Fog
	public static inline function setFog(enable:Bool, color:Color, start:Float, end:Float):Void {
		setFog_impl(enable, color, start, end);
	}
	public static inline function resetFog():Void {
		setFog_impl(false, 0, 0, 1);
	}
	#if (sfgml_next)
	public static var fog(get, set):FogState;
	@:expose("gpu_get_fog") private static function get_fog():FogState;
	@:expose("gpu_set_fog") private static function set_fog_impl(q:FogState):Void;
	private static inline function set_fog(q:FogState):FogState {
		set_fog_impl(q);
		return q;
	}
	@:expose("gpu_set_fog") private static function setFog_impl(z:Bool, c:Color, a:Float, b:Float):Void;
	#else
	@:expose("d3d_set_fog") private static function setFog_impl(z:Bool, c:Color, a:Float, b:Float):Void;
	#end
	//}
	
	//{ Cullmode
	#if (sfgml_next)
	public static var cullMode(get, set):CullMode;
	@:expose("gpu_get_cullmode") private static function get_cullMode():CullMode;
	@:expose("gpu_set_cullmode") private static function set_cullMode_impl(q:CullMode):Void;
	private static inline function set_cullMode(q:CullMode):CullMode {
		set_cullMode_impl(q);
		return q;
	}
	#end
	//}
	
	//{ linear interpolation
	/** Whether linear interpolation is enabled */
	public static var texFilter(get, set):Bool;
	private static inline function set_texFilter(q:Bool):Bool {
		set_texFilter_impl(q);
		return q;
	}
	@:expose("texture_get_interpolation") @:expose2("gpu_get_texfilter")
	private static function get_texFilter():Bool;
	@:expose("texture_set_interpolation") @:expose2("gpu_set_texfilter")
	private static function set_texFilter_impl(q:Bool):Void;
	#if (sfgml_next)
	// todo: _ext
	#end
	//}
	
	//{ texture repeat
	/** Whether texture repeat is enabled */
	public static var texRepeat(get, set):Bool;
	private static inline function set_texRepeat(q:Bool):Bool {
		set_texRepeat_impl(q);
		return q;
	}
	@:expose("texture_get_repeat") @:expose2("gpu_get_texrepeat")
	private static function get_texRepeat():Bool;
	@:expose("texture_set_repeat") @:expose2("gpu_set_texrepeat")
	private static function set_texRepeat_impl(q:Bool):Void;
	#if (sfgml_next)
	// todo: _ext
	#end
	//}
	
	// todo: gpu_tex_ group
	// todo: zfunc
	// todo: ztestenable
	// todo: zwriteenable
	//{
	#if (sfgml_next)
	@:expose("gpu_push_state") public static function pushState():Void;
	@:expose("gpu_pop_state") public static function popState():Void;
	#end
	//}
}
private class GPUImpl {
	
}
