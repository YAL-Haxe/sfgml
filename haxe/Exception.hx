package haxe;
import gml.NativeArray;
import gml.NativeStruct;
import gml.NativeType;
import gml.Syntax;
import gml.Syntax.code;

/**
 * This looks like heck because this class is included before the macros run
 * AND including anything from it causes that to be cursed as well
 * https://github.com/HaxeFoundation/haxe/issues/9346
 * @author YellowAfterlife
 */
#if (macro || eval)
extern class Exception {
	/**
		Exception message.
	**/
	public var message(get,never):String;
	private function get_message():String;

	/**
		The call stack at the moment of the exception creation.
	**/
	public var stack(get,never):CallStack;
	private function get_stack():CallStack;

	/**
		Contains an exception, which was passed to `previous` constructor argument.
	**/
	public var previous(get,never):Null<Exception>;
	private function get_previous():Null<Exception>;

	/**
		Native exception, which caused this exception.
	**/
	public var native(get,never):Any;
	final private function get_native():Any;

	/**
		Used internally for wildcard catches like `catch(e:Exception)`.
	**/
	static private function caught(value:Any):Exception;

	/**
		Used internally for wrapping non-throwable values for `throw` expressions.
	**/
	static private function thrown(value:Any):Any;

	/**
		Create a new Exception instance.

		The `previous` argument could be used for exception chaining.

		The `native` argument is for internal usage only.
		There is no need to provide `native` argument manually and no need to keep it
		upon extending `haxe.Exception` unless you know what you're doing.
	**/
	public function new(message:String, ?previous:Exception, ?native:Any):Void;

	/**
		Extract an originally thrown value.

		Used internally for catching non-native exceptions.
		Do _not_ override unless you know what you are doing.
	**/
	private function unwrap():Any;

	/**
		Returns exception message.
	**/
	public function toString():String;

	/**
		Detailed exception description.

		Includes message, stack and the chain of previous exceptions (if set).
	**/
	public function details():String;

	/**
		If this field is defined in a target implementation, then a call to this
		field will be generated automatically in every constructor of derived classes
		to make exception stacks point to derived constructor invocations instead of
		`super` calls.
	**/
	// @:noCompletion @:ifFeature("haxe.Exception.stack") private function __shiftStack():Void;
}
#elseif ((gml && sfgml.modern) || display)
@:std
class Exception {
	public var message:String;
	
	// Haxe:
	
	/** The call stack at the moment of the exception creation. **/
	public var stack(get, never):CallStack;
	public function get_stack():CallStack {
		if (__exceptionStack == null) {
			var gmlStack = (native:NativeException).stacktrace;
			var len = gmlStack.length;
			var hxStack = NativeArray.createEmpty(len);
			for (i in 0 ... len) hxStack[i] = haxe.CallStack.StackItem.Module(gmlStack[i]);
			__exceptionStack = hxStack;
		}
		return __exceptionStack;
	}
	var __exceptionStack:CallStack;
	
	/** Contains an exception, which was passed to `previous` constructor argument. **/
	public var previous:Null<Exception>;
	
	/**
		Native exception, which caused this exception.
		This is always a NativeException.
	**/
	public var native:Any;
	
	public function new(message:String, ?previous:Exception, ?native:Any) {
		this.message = message;
		this.previous = previous;
		if (native == null) {
			// this is the only way to instantiate a native exception as of 2022.6
			var natEx:NativeException = null;
			Syntax.code("try { show_error({1}, true); } catch(_e) { {0} = _e; }", natEx, message);
			NativeArray.delete(natEx.stacktrace, 0, 1);
			natEx.hxException = this;
			native = natEx;
		}
		this.native = native;
	}
	
	function unwrap():Any {
		return native;
	}
	
	@:keep public function toString():String {
		// if we don't have toString(), an uncaught exception will show JSON of the entire struct
		return message;
	}
	
	static inline function isHaxeException(e:Any) {
		return NativeStruct.hasField(e, "stack");
	}
	static inline function isNativeException(e:Any) {
		return NativeStruct.hasField(e, "stacktrace");
	}
	
	public static function caught(value:Any):Any {
		if (NativeType.isStruct(value)) {
			if (isHaxeException(value)) return value;
			var hxEx = NativeStruct.getField(value, "hxException");
			if (hxEx != null) return hxEx;
			if (isNativeException(value)) {
				hxEx = new Exception((value:NativeException).message, null, value);
				// are there any caveats to caching?
				(value:NativeException).hxException = hxEx;
				return hxEx;
			}
		}
		// GML code must have thrown a custom value
		return new Exception(NativeType.toString(value));
	}
	public static function thrown(value:Any):Any {
		if (NativeType.isStruct(value)) {
			if (isHaxeException(value)) return (value:Exception).native;
			if (isNativeException(value)) return value;
		}
		var message = value is String ? (value:String) : NativeType.toString(value);
		var natEx:NativeException = null;
		Syntax.code("try { show_error({1}, true); } catch(_e) { {0} = _e; }", natEx, message);
		return natEx;
	}
}
typedef NativeException = {
	/** "division by zero" **/
	message:String,
	/** "ERROR in ..." **/
	longMessage:String,
	/** "gml_Script_mydiv" **/
	script:String,
	/** 1 **/
	line:Int,
	/** ["gml_Script_mydiv", "gml_Object_obj_test_Create_0"] **/
	stacktrace:Array<String>,
	
	?hxException:Exception,
}
#else
@:std class Exception {
	public var message:String;
	
	// Haxe:
	public var stack:CallStack;
	public var previous:Null<Exception>;
	public var native:Any;
	
	// GML:
	public var longMessage:String;
	public var script:String;
	public var stacktrace:Array<String>;
	
	public function new(message:String, ?previous:Exception, ?native:Any) {
		this.native = native != null ? native : this;
	}
	public function details():String {
		return "???";
	}
	
	#if (sfgml.modern || sfgml_version >= "2.3")
	#if sfgml_simple_exceptions
	private static inline function wrapValue(val:Any):Dynamic {
		return {
			value: val,
			message: code("string")(val),
			longMessage: "",
			script: "",
			stacktrace: code("debug_get_callstack")(),
			__exception__: true
		};
	}
	private static inline function isNativeException(value:Any):Bool {
		return code("is_struct")(value) && code("variable_struct_get")(value, "__exception__") == true;
	}
	public static function caught(value:Any):Any {
		if (isNativeException(value)) return value;
		var e:Dynamic = wrapValue(value);
		(cast e:Exception).native = e;
		return e;
	}
	public static function thrown(value:Any):Any {
		if (isNativeException(value)) return value;
		var e:Dynamic = wrapValue(value);
		(cast e:Exception).native = e;
		return e;
	}
	#else // !sfgml_simple_exceptions
	private static function isNativeException(value:Any):Bool {
		if (code("is_struct")(value)) {
			var c:Dynamic = code("variable_struct_get")(value, "__class__");
			if (c == null) return false;
			if (c == Exception) return true;
			if (!code("variable_struct_exists")(value, "superClass")) return false;
			c = c.superClass;
			while (code("is_struct")(c)) {
				if (c == Exception) return true;
				c = c.superClass;
			}
		}
		return false;
	}
	public static function caught(value:Any):Any {
		if (isNativeException(value)) return value;
		return new ValueException(value);
	}
	public static function thrown(value:Any):Any {
		if (isNativeException(value)) return (value:Exception).native;
		return new ValueException(value);
	}
	#end // if sfgml_simple_exceptions
	#else // < 2.3
	public static inline function caught(value:Any):Any {
		return value;
	}
	public static inline function thrown(value:Any):Any {
		return code("string")(value);
	}
	#end // if 2.3
	
	#if sfgml_simple_exceptions inline #end
	function unwrap():Any {
		return native;
	}
	
	public function toString():String {
		return message;
	}
}
#end