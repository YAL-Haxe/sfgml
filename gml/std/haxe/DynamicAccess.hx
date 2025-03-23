package haxe;

import gml.NativeStruct;
import haxe.iterators.DynamicAccessIterator;
import haxe.iterators.DynamicAccessKeyValueIterator;

/**
 * Takes some shortcuts instead of using Reflect.
 */
@:std
abstract DynamicAccess<T>(Dynamic<T>) from Dynamic<T> to Dynamic<T> {
	
	public inline function new() this = {};
	
	@:arrayAccess
	public inline function get(key:String):Null<T> {
		return NativeStruct.getField(this, key);
	}
	
	@:arrayAccess
	public inline function set(key:String, value:T):T {
		NativeStruct.setField(this, key, value);
		return value;
	}
	
	public inline function exists(key:String):Bool {
		return NativeStruct.hasField(this, key);
	}
	
	public function remove(key:String):Bool {
		#if (sfgml_version >= "2.3.1")
		var result = NativeStruct.hasField(this, key);
		NativeStruct.deleteField(this, key);
		return result;
		#else
		return Reflect.deleteField(this, key);
		#end
	}
	
	public inline function keys():Array<String> {
		return NativeStruct.getFieldNames(this);
	}
	
	public function copy():DynamicAccess<T> {
		var fields = NativeStruct.getFieldNames(this);
		var r:DynamicAccess<T> = {};
		for (i in 0 ... fields.length) {
			var fd:String = fields[i];
			NativeStruct.setField(r, fd, NativeStruct.getField(this, fd));
		}
		return r;
	}
	
	public inline function iterator():DynamicAccessIterator<T> {
		return new DynamicAccessIterator(this);
	}
	
	public inline function keyValueIterator():DynamicAccessKeyValueIterator<T> {
		return new DynamicAccessKeyValueIterator(this);
	}
}
