package sf;
import sf.SfConfigImpl.*;
/**
 * ...
 * @author YellowAfterlife
 */
class SfConfig extends SfConfigImpl {
	
	/** */
	public var version = int("sfgml-version", -1);
	
	/** Whether to maintain hints of empty types. */
	public var hintEmptyTypes = bool("sf-hint-empty-types", false);
	
	/** Name of the init script. */
	public var entrypoint = string("sfgml-main", "main");
	
	/** File header information, if any */
	public var header = string("sfgml-header");
	
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
	
	/** bug #24929 */
	public var scriptLookup:String = string("sfgml-script-lookup", null);
	
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
		var newish = next || (version < 0 || version > 1763);
		hasArrayCreate = newish;
		ternary = next || gmxMode && newish;
		hasArrayDecl = next || gmxMode && newish;
	}
}
