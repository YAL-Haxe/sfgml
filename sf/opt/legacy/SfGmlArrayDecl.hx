package sf.opt.legacy;

import sf.opt.SfOptImpl;
import sf.type.expr.SfExprDef.*;
import sf.type.*;
import sf.type.expr.*;
import sf.opt.type.*;
using sf.type.expr.SfExprTools;
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
		//
		var arrayDecl = bootType.staticMap["decl"];
		var arrayDeclUsed = SfGmlType.usesProto && !sfConfig.next;
		var arrayDeclUsedKind = arrayDeclUsed ? 1 : 0;
		var arrayDeclUsedAt = null;
		//
		var arrayTrail = bootType.staticMap["trail"];
		var arrayTrailUsed = false;
		//
		var hasArrayCreate = sfConfig.hasArrayCreate;
		var noArrayDecl = !sfConfig.hasArrayDecl;
		if (noArrayDecl) {
			var rType:SfClass = cast sfGenerator.realMap["Type"];
			if (rType != null && rType.staticMap.exists("enumConstructor")) {
				arrayDeclUsed = true;
				arrayDeclUsedKind = 2;
			}
			if (sf.opt.api.SfGml_Type_enumHelpers.code.length > 0) {
				arrayDeclUsed = true;
				arrayDeclUsedKind = 3;
			}
		}
		ignoreHidden = true;
		forEachExpr(function(e:SfExpr, w, f:SfExprIter) {
			switch (e.def) {
				case SfArrayDecl(values): if (noArrayDecl) {
					if (values.length == 0 && hasArrayCreate) {
						e.setTo(SfCall(
							e.mod(SfIdent("array_create")),
							[e.mod(SfConst(TInt(0)))]
						));
					} else {
						e.setTo(SfCall(e.mod(SfStaticField(bootType, arrayDecl)), values));
						arrayDeclUsed = true;
						arrayDeclUsedKind = 4;
						arrayDeclUsedAt = e.getPos();
					}
				};
				case SfNew(c, _, args) if (c == arrayType): {
					if (args.length == 0) args.push(e.mod(SfConst(TInt(0))));
				};
				default:
			}
			e.iter(w, f);
		});
		if (arrayDeclUsedKind != 0) {
			trace(arrayDeclUsedKind, arrayDeclUsedAt);
		} else bootType.removeField(arrayDecl);
		if (!arrayTrailUsed) bootType.removeField(arrayTrail);
	}
	
}
