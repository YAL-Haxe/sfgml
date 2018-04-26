package gml;

/**
 * ...
 * @author YellowAfterlife
 */
@:build(gml.__macro.GmlGenScripts.build())
@:std @:native("")
extern class Scripts {
	#if sfgml_assets_path
	/** Please wait! */
	public static var macroLoading:Dynamic;
	#else
	/** Please specify a valid project path via `sfgml-assets-path` compiler directive */
	public static var macroNotLoaded:Dynamic;
	#end
}
