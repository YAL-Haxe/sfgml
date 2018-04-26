package gml;
import gml.assets.*;

/**
 * ...
 * @author YellowAfterlife
 */
@:build(gml.__macro.GmlGenAssets.build())
@:std @:native("")
extern class Assets {
	#if sfgml_assets_path
	/** Please wait! */
	public static var macroLoading:Dynamic;
	#else
	/** Please specify a valid project path via `sfgml-assets-path` compiler directive */
	public static var macroNotLoaded:Dynamic;
	#end
}
