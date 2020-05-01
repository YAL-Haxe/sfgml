package haxe;
import gml.NativeArray;
import gml.io.Buffer;

/** GML only uses Module for now */
enum StackItem {
	CFunction;
	Module(m:String);
	FilePos(s:Null<StackItem>, file:String, line:Int, ?column:Null<Int>);
	Method(classname:Null<String>, method:String);
	LocalFunction(?v:Int);
}

/**
 * ...
 * @author YellowAfterlife
 */
@:allow(haxe.Exception)
@:using(haxe.CallStack)
abstract CallStack(Array<StackItem>) from Array<StackItem> {
	public var length(get,never):Int;
	inline function get_length():Int return this.length;
	
	public inline function copy():CallStack {
		return this.copy();
	}

	@:arrayAccess public inline function get(index:Int):StackItem {
		return this[index];
	}

	inline function asArray():Array<StackItem> {
		return this;
	}
	
	public function subtract(stack:CallStack):CallStack {
		var startIndex = -1;
		var i = -1;
		while(++i < this.length) {
			for(j in 0...stack.length) {
				if(equalItems(this[i], stack[j])) {
					if(startIndex < 0) {
						startIndex = i;
					}
					++i;
					if(i >= this.length) break;
				} else {
					startIndex = -1;
				}
			}
			if(startIndex >= 0) break;
		}
		return startIndex >= 0 ? this.slice(0, startIndex) : this;
	}
	
	static function equalItems(item1:Null<StackItem>, item2:Null<StackItem>):Bool {
		return switch([item1, item2]) {
			case [null, null]: true;
			case [CFunction, CFunction]: true;
			case [Module(m1), Module(m2)]:
				m1 == m2;
			case [FilePos(item1, file1, line1, col1), FilePos(item2, file2, line2, col2)]:
				file1 == file2 && line1 == line2 && col1 == col2 && equalItems(item1, item2);
			case [Method(class1, method1), Method(class2, method2)]:
				class1 == class2 && method1 == method2;
			case [LocalFunction(v1), LocalFunction(v2)]:
				v1 == v2;
			case _: false;
		}
	}
	
	private static var toString_buf:Buffer = Buffer.defValue;
	public static function toString(s:CallStack):String {
		var b = toString_buf;
		if (b == Buffer.defValue) {
			b = new Buffer(1024, Grow, 1);
			toString_buf = b;
		}
		b.rewind();
		var n = s.length;
		var i = -1; while (++i < n) {
			if (i > 0) b.writeByte('\n'.code);
			var item = s[i];
			switch (item) {
				case StackItem.Module(m): {
					b.writeChars(m);
				};
				default: b.writeChars("???");
			}
		}
		b.writeByte(0);
		b.rewind();
		return b.readString();
	}
	
	public static function callStack():Array<StackItem> {
		var raw:Array<String> = SfTools.raw("debug_get_callstack")();
		var n = raw.length - 1;
		var arr:Array<StackItem> = NativeArray.createEmpty(n);
		var i = -1; while (++i < n) {
			arr[i] = Module(raw[i + 1]);
		}
		return arr;
	}
	
	public static function exceptionStack():Array<StackItem> {
		var raw:Array<String> = SfTools.raw("debug_get_callstack")();
		var n = raw.length - 1;
		var arr:Array<StackItem> = NativeArray.createEmpty(n);
		var i = -1; while (++i < n) {
			arr[i] = Module(raw[i + 1]);
		}
		return arr;
	}
	
	#if (haxe >= "4.1.0")
	public static function exceptionToString(e:Exception):String {
		if(e.previous == null) {
			return 'Exception: ${e.message}${e.stack}';
		}
		var result = '';
		var e:Null<Exception> = e;
		var prev:Null<Exception> = null;
		while(e != null) {
			if(prev == null) {
				result = 'Exception: ${e.message}${e.stack}' + result;
			} else {
				var prevStack = @:privateAccess e.stack.subtract(prev.stack);
				result = 'Exception: ${e.message}${prevStack}\n\nNext ' + result;
			}
			prev = e;
			e = e.previous;
		}
		return result;
	}
	#end
}