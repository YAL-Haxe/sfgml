package gml;
import gml.NativeScope.WithIter;
import gml.assets.Object;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.extern.EitherType;

/**
 * ...
 * @author YellowAfterlife
 */
#if (!macro) @:native("") #end
@:keep @:remove @:std extern class NativeScope {
	
	/** instance currently executing the code */
	public static var self(default, never):Instance;
	//private static inline function get_self():Instance return untyped __raw__("self");
	
	/** "other" instance inside with-loops and collision events, equal to self otherwise */
	public static var other(default, never):Instance;
	//private static inline function get_other():Instance return untyped __raw__("other");
	
	/** it's equal to -4, so be careful with that */
	public static var noone(default, never):Instance;
	
	/** `for (q in NativeScope.with(MyObject)) trace(q.x)` -> `with (MyObject) trace(x)`*/
	@:overload(function<T:Instance>(filter:WithFilter<T>, ?t:Class<T>):WithIter<T> {})
	//@:overload(function<T:Instance>(filter:WithFilter<T>):WithIter<Instance> {})
	public static function with<T:Instance>(filter:WithFilter<T>):WithIter<Instance>;
}

private typedef WithFilter<T> = EitherType<EitherType<T, Class<T>>, Object>;

extern class WithIter<T> {
	public function new(filter:Dynamic);
	public function hasNext():Bool;
	public function next():T;
}
