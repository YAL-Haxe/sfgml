package sys.io;

import gml.io.Buffer;
import haxe.io.Input;

/**
 * ...
 * @author YellowAfterlife
 */
#if !sfgml_native_bytes
class FileInput extends Input {
	function new(path:String) {
		var buf = Buffer.load(path);
		var size = buf.length;
		var d = gml.NativeArray.create(size);
		for (i in 0 ... size) {
			d[i] = buf.readByte();
		}
		buf.destroy();
		this.data = d;
		this.dataPos = 0;
		this.dataLen = size;
	}
	public inline function tell():Int {
		return this.dataPos;
	}
	public inline function seek(p:Int, rel:FileSeek):Void {
		switch (rel) {
			case FileSeek.SeekCur: dataPos += p;
			case FileSeek.SeekEnd: dataPos = dataLen - p;
			default: dataPos = p;
		}
	}
	public inline function eof():Bool {
		return dataPos >= dataLen;
	}
}
#else
class FileInput extends Input {
	
	inline function new(path:String) {
		buf = Buffer.load(path);
	}
	
	public inline function tell():Int {
		return buf.position;
	}
	
	public inline function seek(pos:Int, rel:FileSeek):Void {
		buf.seek(cast rel, pos);
	}
	
	public inline function eof():Bool {
		return buf.position >= buf.size;
	}
}
#end
