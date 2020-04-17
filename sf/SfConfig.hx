package sf;
import haxe.io.Path;
import haxe.macro.Compiler;
import sf.SfConfigImpl.*;
/**
 * ...
 * @author YellowAfterlife
 */
class SfConfig extends SfConfigImpl {
	
	// default target versions (if not specified):
	static inline var defVersion1:String = "1.4.1804";
	static inline var defVersion2:String = "2.2.1";
	
	/** */
	public var version = string("sfgml-version", null);
	
	/** Whether to maintain hints of empty types. */
	public var hintEmptyTypes = bool("sf-hint-empty-types", false);
	
	/** Name of the init script. */
	public var entrypoint = string("sfgml-main", "main");
	
	/** File header information, if any */
	public var header = string("sfgml-header");
	
	/** Whether to include timestamp+generation time in header */
	public var timestamp = bool("sfgml-timestamp", true);
	
	/** trace() function name */
	public var traceFunc = string("sfgml-trace", "trace");
	
	/** Prefix for local variables (for max compatibility) */
	public var localPrefix = string("sfgml-local", "");
	
	/** File to modify in the extension */
	public var gmxFile = string("sfgml-ext-file", string("sfgml-gmx-file", null));
	
	/** Whether to hint functions in the extension */
	public var gmxDoc = bool("sfgml-gmx-doc", true);
	
	/** Whether to hint macros' documentation in extension by adding a separate macros */
	public var gmxMcrDoc = bool("sfgml-gmx-macro-doc", true);
	
	/** Whether to omit /// comments in code */
	public var noCodeDoc = bool("sfgml-no-code-doc", false);
	
	/** Whether compiled to an extension (can output macros) */
	public var gmxMode = false;
	
	/** Whether to use GMS2-specific syntax */
	public var next:Bool = bool("sfgml-next");
	
	/** Whether to allocate indexes for field names (for readability in debugger) */
	public var fieldNames:Bool = bool("sfgml-field-names", false);
	
	/** Whether to store all instance methods as dynamic functions */
	public var dynMethods:Bool = bool("sfgml-dyn-methods", false);
	
	/** Whether to output :type hints */
	public var argTypes:Bool = bool("sfgml-arg-types", true);
	
	/** Whether to auto-apply snake_case convention to all non-@:native'd items. */
	public var snakeCase:Bool = bool("sfgml-snake-case", false);
	
	/** Allows to generate a multi-script file separately from an extension */
	public var codePath:String = string("sfgml-code-path", null);
	
	/** If set, all scripts are wrapped in if (<expr>) { ... } else return @:defValue */
	public var printIf:String = string("sfgml-print-if", null);
	
	/** https://bugs.yoyogames.com/view.php?id=24929 */
	public var scriptLookup:String = string("sfgml-script-lookup", null);
	
	/** https://bugs.yoyogames.com/view.php?id=29203 */
	public var scriptExecuteWrap:String = string("sfgml-script-execute-wrap", null);
	
	/** Whether to allow custom metadata setting */
	public var customMeta:Bool = bool("sfgml-custom-meta");
	
	/** Whether to include :type comments for primitives */
	public var hintVarTypes:Bool = bool("sfgml-hint-var-types");
	
	/** Whether array_create() is suppported */
	public var hasArrayCreate:Bool;
	
	/** Whether [...] array initializer is supported */
	public var hasArrayDecl:Bool;
	
	/** Whether try-catch is supported */
	public var hasTryCatch:Bool;
	
	/** Whether function(){} is supported */
	public var hasFunctionLiterals:Bool;
	
	/** Whether a[i][k] is supported */
	public var hasChainedAccessors:Bool;
	
	/** >=2.3 */
	public var modern:Bool;
	
	/** Whether to use function(){} at top-level */
	public var topLevelFuncs:Bool;
	
	/** Whether copy-on-write behaviour works correctly */
	public var copyset:Bool;
	
	/** https://bugs.yoyogames.com/view.php?id=29749 */
	public var slowTernary:Bool = true;
	
	/** https://bugs.yoyogames.com/view.php?id=30411 */
	public var slowPostfix:Bool = true;
	
	/** Stores type information in [1,0] instead of [0] */
	public var legacyMeta:Bool = bool("sfgml-legacy-meta");
	
	public function new() {
		super();
		instanceof = true;
		update();
	}
	public function update() {
		var d = findData();
		hasArrayCreate = d.array_create;
		hasArrayDecl = d.array_decl;
		//Sys.println(d);
		ternary = d.ternary;
		copyset = d.copyset;
		slowPostfix = compare(d.version, "2.2.3") < 0;
		var v23 = compare(d.version, "2.3") >= 0;
		modern = v23;
		hasTryCatch = v23;
		hasFunctionLiterals = v23;
		hasChainedAccessors = v23;
		topLevelFuncs = v23 && !gmxMode;
	}
	static var findVersion_1:SfGmlVersion = null;
	static function findVersion():SfGmlVersion {
		var d = findVersion_1;
		if (d != null) return d;
		var v = value("sfgml_version");
		var next = bool("sfgml_next", null);
		var modern = bool("sfgml_modern", null);
		//
		var path = Compiler.getOutput();
		if (Path.extension(path) == "_") path = Path.withoutExtension(path);
		var ext:Bool;
		switch (Path.extension(path).toLowerCase()) {
			case "gmx": ext =  true; next = false;
			case "yy":  ext =  true; next = true;
			default:    ext = false;
		}
		//
		if (next == null && v != null) next = compare(v, "2") >= 0;
		if (modern == null && v != null) modern = compare(v, "2.3") >= 0;
		//
		return { version: v, next: next, extension: ext, modern: modern };
	}
	static function findData(?vd:SfGmlVersion):SfGmlFeatures {
		if (vd == null) vd = findVersion();
		var v = vd.version;
		var next = vd.next;
		inline function vc(o:String):Int {
			return compare(v, o);
		}
		//
		var gml2 = next || (vd.extension && vc("1.4.1763") > 0);
		return {
			version: v,
			next: next,
			modern: vd.modern,
			extension: vd.extension,
			array_create: bool("sfgml_array_create", gml2),
			array_decl: bool("sfgml_array_decl", gml2),
			ternary: bool("sfgml_ternary", gml2),
			copyset: false, // https://bugs.yoyogames.com/view.php?id=29731
		};
	}
	public static function main() {
		inline function def<T>(name:String, val:T):Void {
			if (value(name) == null) Compiler.define(name, Std.string(val));
		}
		//
		var vd = findVersion();
		if (vd.version == null) {
			vd.version = vd.next ? defVersion2 : defVersion1;
			Compiler.define("sfgml_version", vd.version);
		}
		findVersion_1 = vd;
		if (vd.next) def("sfgml_next", true);
		def("sfgml_extension", vd.extension);
		//
		var d = findData(vd);
		def("sfgml_array_create", d.array_create);
		def("sfgml_array_decl", d.array_decl);
		def("sfgml_ternary", d.ternary);
		def("sfgml_copyset", d.copyset);
		def("sfgml.modern", d.modern);
	}
}
private typedef SfGmlVersion = {
	next:Bool,
	modern:Bool,
	version:String,
	extension:Bool,
}
private typedef SfGmlFeatures = { >SfGmlVersion,
	array_create:Bool,
	array_decl:Bool,
	ternary:Bool,
	copyset:Bool,
}
