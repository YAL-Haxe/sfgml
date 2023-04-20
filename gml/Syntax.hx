package gml;
import haxe.macro.Context;
import haxe.macro.Expr;

class Syntax {
	/**
	 * This is like your regular platform.Syntax.code, BUT:
	 * You may specify argument type, e.g.
	 * Syntax.code("with (${x0}) ${s0}", myObj, trace(untyped self));
	 * to force an argument to be printed as an inline expression (x#) or a statement (s#).
	 * 
	 * If you do not hint an argument type, it will be auto-detected based on surrounding code.
	 */
	public static macro function code(e:Array<Expr>):ExprOf<Dynamic> {
		var pos = Context.currentPos();
		if (e.length < 1) Context.error("code() requires at least one argument.", pos);
		var raw = macro @:pos(pos) untyped __raw__;
		return { expr: ECall(raw, e), pos: pos };
	}
	
	/**
	 * Generates a GML-specific integer division operation.
	 * Note: As of writing this (June 2020), result is 32-bit, thus subject to overflow.
	 */
	public static inline function div(a:Float, b:Float):Int {
		return code("({0} div {1})", a, b);
	}
	
	public static inline function delete(x:Any):Void {
		code("delete {0}", x);
	}
}