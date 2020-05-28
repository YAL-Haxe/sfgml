package sf.gml;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class SfGmlTools {
	
	/**
	 * Returns whether the expression starting at <pos> in <gml> looks inline
	 * (as opposed to being a statement)
	 */
	public static function isInline(gml:String, pos:Int, def:Bool = true):Bool {
		while (--pos >= 0) {
			var c = gml.fastCodeAt(pos);
			switch (c) {
				case " ".code, "\t".code, "\r".code, "\n".code: {};
				case ")".code, "{".code, "}".code: return false;
				case "(".code: {
					while (--pos >= 0) {
						c = gml.fastCodeAt(pos);
						switch (c) {
							case " ".code, "\t".code, "\r".code, "\n".code: {};
							default: {
								return !(pos >= 2 && c == "r".code
									&& gml.fastCodeAt(pos - 1) == "o".code
									&& gml.fastCodeAt(pos - 2) == "f".code
								);
							};
						}
					}
				};
				case"+".code, "-".code, "*".code, "/".code, "%".code,
					"<".code, ">".code, "&".code, "|".code, "^".code,
				"=".code: return true;
				default: return def;
			}
		}
		return def;
	}
}