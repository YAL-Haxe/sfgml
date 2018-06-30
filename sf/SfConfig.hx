package sf;
import haxe.macro.Compiler;
import sf.SfConfigImpl.*;
/**
 * ...
 * @author YellowAfterlife
 */
class SfConfig extends SfConfigImpl {
	
	// default target versions (if not specified):
	static inline var defVersion1:String = "1.4.1804";
	static inline var defVersion2:String = "2.1.4";
	
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
	
	/** Whether array_create() is suppported */
	public var hasArrayCreate:Bool;
	
	/** Whether [...] array initializer is supported */
	public var hasArrayDecl:Bool;
	
	public function new() {
		super();
		instanceof = true;
		update();
	}
	public function update() {
		var newish:Bool;
		if (!next) {
			newish = compare(version, "1.4.1763") > 0;
		} else newish = true;
		hasArrayCreate = newish;
		ternary = next || gmxMode && newish;
		hasArrayDecl = compare(version, "2.2") >= 0;
	}
	public static function main() {
		inline function def<T>(name:String, val:T):Void {
			if (value(name) == null) Compiler.define(name, Std.string(val));
		}
		//
		var v2 = bool("sfgml_next");
		var v = value("sfgml_version");
		inline function vc(o:String):Int {
			return compare(v, o);
		}
		if (v == null) {
			v = v2 ? defVersion2 : defVersion1;
			def("sfgml_version", v);
		}
		// features
		def("sfgml_array_create", v2 || vc("1.4.1763") > 0);
		def("sfgml_array_decl", vc("2.2") >= 0); // https://bugs.yoyogames.com/view.php?id=29731
	}
}
