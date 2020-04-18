package gml;
import gml.assets.Script;
import haxe.Constraints.Function;

/**
 * >=2.3
 * @author YellowAfterlife
 */
@:std
extern class NativeFunction {
	/**
	 * [re-]binds a script to run on specified instance.
	 * More or less equivalent of ES Function:bind.
	 */
	@:expose("method")
	public static function bind<T:Function>(self:Dynamic, fn:T):T;
	
	/**
	 * Returns the underlying script index for the specified method.
	 */
	@:expose("method_get_index")
	public static function getScript(fn:Function):Script;
	
	/** Returns the instance that is bound to the specified method. */
	@:expose("method_get_self")
	public static function getSelf(fn:Function):Dynamic;
	
	public static inline function call(fn:Function, args:Array<Dynamic>, ?argc:Int):Dynamic {
		return gml.internal.NativeFunctionInvoke.call(fn, args, argc);
	}
}
