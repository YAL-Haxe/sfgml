package sf.opt;

import sf.opt.SfOptImpl;
import sf.type.SfExprDef.*;
import sf.type.*;
using sf.type.SfExprTools;
import sf.SfCore.*;
import haxe.macro.Expr.Binop.*;

/**
 * GMS1 can't do [...] so there are array_decl and array_trail methods to be generated for that.
 * @author YellowAfterlife
 */
class SfGmlArrayDecl extends SfOptImpl {
	
	override public function apply() {
		var arrayType:SfClass = sfGenerator.typeArray;
		var bootType:SfClass = sfGenerator.typeBoot;
		if (bootType == null) return;
		var arrayDecl = bootType.staticMap["decl"];
		var arrayDeclUsed = SfGmlType.usesProto && !sfConfig.next;
		var arrayTrail = bootType.staticMap["trail"];
		var arrayTrailUsed = false;
		#if !sfgml_next
		var rType:SfClass = cast sfGenerator.realMap["Type"];
		if (rType != null && rType.staticMap.exists("enumConstructor")) arrayDeclUsed = true;
		#end
		forEachExpr(function(e:SfExpr, w, f:SfExprIter) {
			switch (e.def) {
				#if !sfgml_next
				case SfArrayDecl(values): {
					#if (!sfgml_version || sfgml_version > 1763)
					if (values.length == 0) {
						e.setTo(SfCall(
							e.mod(SfDynamic("array_create", [])),
							[e.mod(SfConst(TInt(0)))]
						));
					} else 
					#end
					e.setTo(SfCall(e.mod(SfStaticField(bootType, arrayDecl)), values));
					arrayDeclUsed = true;
				};
				#end
				case SfNew(c, _, args) if (c == arrayType): {
					if (args.length == 0) args.push(e.mod(SfConst(TInt(0))));
				};
				default:
			}
			e.iter(w, f);
		});
		if (!arrayDeclUsed) bootType.removeField(arrayDecl);
		if (!arrayTrailUsed) bootType.removeField(arrayTrail);
	}
	
}
