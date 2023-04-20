package gml;
import gml.assets.Script;
import haxe.Constraints.Function;
import haxe.DynamicAccess;

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
	
	/** 2023.1 and newer */
	@:expose("static_get")
	public function getStatics():DynamicAccess<Any>;
	
	/** 2023.1 and newer */
	@:expose("static_set")
	public function setStatics(struct:DynamicAccess<Any>):Void;
}
