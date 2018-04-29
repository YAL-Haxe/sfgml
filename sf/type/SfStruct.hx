package sf.type;
import haxe.macro.Type.MetaAccess;

/**
 * ...
 * @author YellowAfterlife
 */
class SfStruct extends SfStructImpl {
	override public function metaHandle(meta:MetaAccess, ndoc:String) {
		super.metaHandle(meta, ndoc);
		if (SfCore.sfConfig.next) {
			var exp = metaString(":expose2");
			if (exp != null && exp != "") exposePath = exp;
		}
	}
}
