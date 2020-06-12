package haxe;
@:std @:coreApi class ValueException extends Exception {
	/**
		Thrown value.
	**/
	public var value(default,null):Any;

	public function new(value:Any, ?previous:Exception, ?native:Any):Void {
		super(
			#if (gml && !macro && !eval)
			gml.Syntax.code("string")(value)
			#else
			Std.string(value)
			#end
		, previous, native);
		this.value = value;
	}

	/**
		Extract an originally thrown value.

		This method must return the same value on subsequent calls.
		Used internally for catching non-native exceptions.
		Do _not_ override unless you know what you are doing.
	**/
	override function unwrap():Any {
		return value;
	}
}