package haxe.io;

/**
 * ...
 * @author YellowAfterlife
 */
#if (gml && !macro)
	#if (sfgml_native_bytes)
	typedef BytesData = gml.io.Buffer;
	#else
	typedef BytesData = Array<Int>;
	#end
#elseif neko
	typedef BytesData =	neko.NativeString;
#elseif flash
	typedef BytesData =	flash.utils.ByteArray;
#elseif php
	typedef BytesData = php.BytesData;
#elseif cpp
	extern class Unsigned_char__ { }
	typedef BytesData = Array<Unsigned_char__>;
#elseif java
	typedef BytesData = java.NativeArray<java.StdTypes.Int8>;
#elseif cs
	typedef BytesData = cs.NativeArray<cs.StdTypes.UInt8>;
#elseif python
	typedef BytesData = python.Bytearray;
#elseif js
	typedef BytesData = js.html.ArrayBuffer;
#elseif hl
	class BytesDataImpl {
		public var b : hl.types.Bytes;
		public var length : Int;
		public function new(b,length) {
			this.b = b;
			this.length = length;
		}
	}
	typedef BytesData = BytesDataImpl;
#else
	typedef BytesData = Array<Int>;
#end
