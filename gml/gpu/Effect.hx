package gml.gpu;
import haxe.DynamicAccess;
import haxe.Rest;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("fx") @:snakeCase
extern class Effect {
	function new(name:String);
	function getName():String;
	
	function getParameter(paramName:String):Void;
	function getParameters():DynamicAccess<Any>;
	function getParameterNames():Array<String>;
	
	function setParameter(paramName:String, values:Rest<Any>):Void;
	@:native("set_parameter") function setParameterFloats(paramName:String, values:Rest<Float>):Void;
	@:native("set_parameter") function setParameterArray(paramName:String, values:Array<Float>):Void;
	function setParameters(params:DynamicAccess<Any>):Void;
}