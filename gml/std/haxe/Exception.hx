package haxe;
import haxe.CallStack;

/**
 * ...
 * @author YellowAfterlife
 */
class Exception implements NativeException {
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
		this.message = message;
	}
}

interface NativeException {
	public var message:String;
	public var longMessage:String;
	public var script:String;
	public var stacktrace:Array<String>;
}