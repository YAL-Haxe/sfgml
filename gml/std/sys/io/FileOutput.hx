package sys.io;

import gml.io.Buffer;
import gml.io.BufferKind;
import haxe.io.Output;

/**
 * ...
 * @author YellowAfterlife
 */
#if !sfgml_native_bytes
class FileOutput extends Output {
	private static var buffer:Buffer = new Buffer(32, Grow, 1);
	private var path:String;
	
	public function new(path:String) {
		this.path = path;
	}
	
	public inline function tell():Int {
		return dataPos;
	}
	
	public inline function seek(p:Int, rel:FileSeek):Void {
		switch (rel) {
			case FileSeek.SeekCur: dataPos += p;
			case FileSeek.SeekEnd: dataPos = dataLen - p;
			default: dataPos = p;
		}
	}
	override public function close() {
		var d = data;
		var n = dataPos;
		var b = buffer;
		if (b.length < n) b.resize(n);
		b.rewind();
		for (i in 0 ... n) b.writeByte(d[i]);
		b.savePart(path, 0, n);
	}
}
#else
class FileOutput extends Output {
	private var path:String;
	private inline function new(path:String) {
		this.path = path;
		buf = new Buffer(1024, BufferKind.Grow, 1);
	}
	public inline function tell():Int {
		return buf.position;
	}
	public inline function seek(pos:Int, rel:FileSeek):Void {
		buf.seek(rel, pos);
	}
	override public function close() {
		buf.savePart(path, 0, buf.tell());
		super.close();
	}
}
#end
