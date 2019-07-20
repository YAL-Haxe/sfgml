package sf.type;
import haxe.macro.Type.MetaAccess;

/**
 * ...
 * @author YellowAfterlife
 */
class SfStruct extends SfStructImpl {
	/** (0 = no hint, 1 = :doc, -1 = :noDoc) */
	public var docState:Int = 0;
	
	/** Returns whether the structure should show up in auto-completion. */
	public function checkDocState(parState:Int):Bool {
		if (parState < 0 || docState < 0 || isAutogen) return false;
		return parState > 0 || docState > 0;
	}
	
	override public function metaHandle(meta:MetaAccess, ndoc:String) {
		super.metaHandle(meta, ndoc);
		// GMS2-specific expose path for multi-version output
		if (SfCore.sfConfig.next) {
			var exp = metaString(":expose2");
			if (exp != null && exp != "") exposePath = exp;
		}
		//
		if (exposePath != null) docState = 1;
		var mdoc = metaGetText(meta, ":doc", 3);
		if (mdoc != null) {
			if (mdoc != "") doc = mdoc; // :doc("text")
			docState = 1;
		}
		if (meta.has(":noDoc")) docState = -1;
		//
		if (doc != null) doc = StringTools.trim(doc);
	}
}
