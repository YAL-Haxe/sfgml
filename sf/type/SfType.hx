package sf.type;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Type.BaseType;

/**
 * ...
 * @author YellowAfterlife
 */
class SfType extends SfTypeImpl {
	
	/** Type index */
	public var index:Int = -1;
	
	/** Total type indexes */
	public static var indexes:Int = 0;
	
	/** Whether the type is referenced anywhere */
	public var isUsed:Bool = false;
	
	/** Whether the type is direcently referenced and we need to generate a mt_ for it */
	public var hasTypeExpr:Bool = false;
	
	public function hasMetaType():Bool {
		if (hasTypeExpr) return true;
		if (isHidden || nativeGen) return false;
		if (!isUsed) return false;
		if (Std.is(this, SfEnum)) {
			return !(cast this:SfEnum).isFake;
		} else if (Std.is(this, SfClass)) {
			var c:SfClass = cast this;
			return !(c.constructor == null && c.instList.length == 0);
		} else return false;
	}
	
	/** Classes marked `@:std` get unprefixed variable access. */
	public var isStd:Bool;
	
	/**
	 * Uses 2.3 structs as an underlying type.
	 * If false, instance functions shall take "this" as the first argument,
	 * and 
	 */
	public var isStruct:Bool = false;
	
	/**
	 * Whether to do q.<instField> instead of q[<instField index>].
	 * Types with isStruct=true will have dotAccess=true, but not necessarily
	 * the opposite - for example, GameMaker instances ( @see gml.Instance)
	 * use dotAccess, but are not structs, thus are passed to functions.
	 */
	public var dotAccess:Bool = false;
	
	/**
	 * Whether dotAccess should apply to static fields.
	 * This is controlled via -D sfgml_dot_static in 2.3, default is true.
	 */
	public var dotStatic:Bool = false;
	
	private static var new_stdDir:String = null;
	private static var new_sfgmlDir:String = null;
	private static var new_sfhxDir:String = null;
	public function new(t:BaseType) {
		//
		#if sfgml_doc_is_toplevel
		if (!isStd && !t.meta.has(":native") && !t.meta.has(":expose")) {
			var hasDoc = t.meta.has(":doc");
			if (!hasDoc) {
				if (Std.is(this, SfClass)) {
					var ct:ClassType = cast t;
					var ctr = ct.constructor;
					if (ctr != null && ctr.get().meta.has(":doc")) {
						hasDoc = true;
					} else {
						for (ff in [ct.fields, ct.statics]) {
							for (f in ff.get()) {
								if (f.meta.has(":doc")) { hasDoc = true; break; }
							}
							if (hasDoc) break;
						}
					}
				} else if (Std.is(this, SfEnum)) {
					for (c in (cast t:EnumType).constructs) {
						if (c.meta.has(":doc")) { hasDoc = true; break; }
					}
				}
			}
			if (hasDoc) t.pack.splice(0, t.pack.length);
		}
		#end
		//
		super(t);
		// figure out whether this is a standard library class:
		if (t.meta.has(":std")) {
			isStd = true;
		} else {
			if (new_stdDir == null) {
				new_stdDir = Path.normalize(Path.directory(Context.resolvePath("Any.hx")));
				new_sfhxDir = Path.normalize(Path.directory(Context.resolvePath("SfTools.hx")));
				var path_sfgml_gml = Path.directory(Context.resolvePath("gml/Lib.hx"));
				var path_sfgml = Path.directory(path_sfgml_gml);
				new_sfgmlDir = Path.normalize(path_sfgml);
			}
			var path = Path.normalize(Context.getPosInfos(t.pos).file);
			isStd = StringTools.startsWith(path, new_stdDir)
				||  StringTools.startsWith(path, new_sfhxDir)
				||  StringTools.startsWith(path, new_sfgmlDir);
		}
		//
		if (SfCore.sfConfig.modern) {
			var preferLinear = isStd && isExtern;
			#if sfgml_linear
			preferLinear = true;
			#end
			if (preferLinear) {
				isStruct = t.meta.has(":gml.struct");
			} else {
				isStruct = !isExtern && !t.meta.has(":gml.linear");
			}
			if (isStruct) {
				dotAccess = true;
				if (SfCore.sfConfig.dotStatic) {
					if (!meta.has(":gml.flat_static")) dotStatic = true;
				} else {
					if (meta.has(":gml.dot_static")) dotStatic = true;
				}
			}
		}
	}
}
