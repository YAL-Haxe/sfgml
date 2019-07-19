package sf.type;
import haxe.macro.Type;
import sf.SfCore.*;
import sf.type.SfTypeMap;

/**
 * @author YellowAfterlife
 */
class SfBuffer extends SfBufferImpl {
	override public function addLine(delta:Int = 0) {
		if (delta != 0) this.indent += delta;
		addChar("\r".code);
		addChar("\n".code);
		#if (sfgml_spaces)
		var i = indent << 2; while (--i >= 0) addChar(" ".code);
		#else
		var i = indent; while (--i >= 0) addChar("\t".code);
		#end
	}
	public inline function addTypePathAuto(t:SfType) {
		addTypePath(t, "_".code);
	}
	public inline function addFieldPathAuto(f:SfField) {
		addFieldPath(f, "_".code, "_".code);
	}
	private static var docNameFieldsCache:SfTypeMap<String> = new SfTypeMap();
	private static function docNameFields(dt:DefType):String {
		switch (dt.type) {
			case TAnonymous(_.get() => at): {
				var b = new StringBuf();
				var sep = false;
				if (dt.meta.has(":dsMap")) {
					b.add("map{");
					for (fd in at.fields) {
						if (sep) b.add("; "); else sep = true;
						if (fd.meta.has(":optional")) b.add("?");
						b.add(fd.name);
					}
					b.add("}");
				} else {
					b.add("[");
					for (fd in at.fields) {
						if (sep) b.add("; "); else sep = true;
						if (fd.meta.has(":optional")) b.add("?");
						b.add(fd.name);
					}
					b.add("]");
				}
				return b.toString();
			};
			default: return dt.name;
		}
	}
	public function addBaseTypeName(ot:Type) {
		var pack:Array<String>, par:Array<Type>, i:Int, n:Int, s:String;
		inline function f(t:BaseType, ?p:Array<Type>, ?dt:DefType) {
			s = t.name;
			if (t.meta.has(":docNameFields") && dt != null) {
				s = docNameFieldsCache.baseGet(t);
				if (s == null) {
					s = docNameFields(dt);
					docNameFieldsCache.baseSet(t, s);
				}
			}
			else if (t.meta.has(":docName")) {
				switch (t.meta.extract(":docName")) {
					case [{ params: [{ expr: EConst(CString(s1)) }] }]: s = s1;
					default:
				}
			}
			addString(s);
			par = p;
			if (par != null) {
				n = par.length;
				if (n > 0) {
					addChar("<".code);
					i = 0;
					while (i < n) {
						if (i > 0) addChar2(";".code, " ".code);
						addBaseTypeName(par[i]);
						i += 1;
					}
					addChar(">".code);
				}
			}
		}
		switch (ot) {
			case TEnum(_.get() => et, p): f(et, p);
			case TInst(_.get() => ct, p): f(ct, p);
			case TType(_.get() => dt, p): f(dt, p, dt);
			case TFun(args, ret): {
				n = args.length;
				addString("function[");
				i = 0; while (i < n) {
					if (i > 0) addString("; ");
					var s = args[i].name;
					if (s != null && s != "") {
						addString(args[i].name);
						addChar(":".code);
					}
					addBaseTypeName(args[i].t);
					i += 1;
				}
				addChar2("]".code, ":".code);
				addBaseTypeName(ret);
			};
			case TDynamic(t): {
				addString("dynamic");
				if (t != null) {
					addChar("<".code);
					addBaseTypeName(t);
					addChar(">".code);
				}
			};
			case TLazy(_() => t): addBaseTypeName(t);
			case TAbstract(_.get() => at, p): {
				switch (at.module) {
					case "StdTypes": switch (at.name) {
						case "Null": {
							addString("null<");
							addBaseTypeName(p[0]);
							addString(">");
						};
						case "Bool": addString("bool");
						case "Int": addString("int");
						case "Float": addString("real");
						case "String": addString("string");
						case "Void": addString("void");
						default: f(at, p);
					};
					case "Any": addString("any");
					case "Class": {
						if (p.length > 0) switch (p[0]) {
							case TInst(_.get() => { name: "instance" }, _): {
								addString("object");
							};
							default: f(at, p);
						} else f(at, p);
					};
					default: f(at, p);
				}
			}
			default: addString("?");
		}
	}
}
