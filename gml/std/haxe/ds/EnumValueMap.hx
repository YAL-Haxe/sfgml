package haxe.ds;

/**
	Slightly simpler than Haxe std version
**/
class EnumValueMap<K:EnumValue, V> extends haxe.ds.BalancedTree<K, V> implements haxe.Constraints.IMap<K,V> {

	override function compare(k1:EnumValue, k2:EnumValue):Int {
		return compareArgs(cast k1, cast k2);
	}

	inline function compareArgs(a1:Array<Dynamic>, a2:Array<Dynamic>):Int {
		var ld = a1.length - a2.length;
		if (ld != 0) return ld;
		var d:Int = 0;
		for (i in 0 ... a1.length) {
			var v1 = a1[i], v2 = a2[i];
			if (Std.is(v1, Array) && Std.is(v2, Array)) {
				d = compareArgs(v1, v2);
			} else d = Reflect.compare(v1, v2);
			if (d != 0) break;
		}
		return d;
	}
}
