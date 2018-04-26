package sys.io;
import gml.io.Buffer;
import gml.io.TextFile;
import haxe.io.Bytes;
import SfTools.raw;
import haxe.io.BytesData;

/**
 * ...
 * @author YellowAfterlife
 */
#if (!macro) @:native("file_hx") #end
@:std class File {
	
	#if !sfgml_native_bytes
	private static function getBytesData(path:String):BytesData {
		var buf = Buffer.load(path);
		var size = buf.length;
		var d = gml.NativeArray.create(size);
		for (i in 0 ... size) {
			d[i] = buf.readByte();
		}
		buf.destroy();
		return d;
	}
	#end
	
	public static inline function getContent(path:String):String {
		if (sys.FileSystem.exists(path)) {
			var loadBuf = Buffer.load(path);
			var loadStr = loadBuf.length > 0 ? loadBuf.readString() : "";
			loadBuf.destroy();
			return loadStr;
		} else return null;
	}
	
	public static inline function saveContent(path:String, text:String):Void {
		var saveFile = TextFile.write(path);
		if (saveFile != TextFile.none) {
			saveFile.writeString(text);
			saveFile.close();
		}
	}
	
	#if !sfgml_native_bytes
	private static var buffer:Buffer = new Buffer(32, Grow, 1);
	public static inline function getBytes(path:String):Bytes {
		return Bytes.ofData(getBytesData(path));
	}
	public static function saveBytes(path:String, bytes:Bytes):Void {
		var d = bytes.getData();
		var size = bytes.length;
		var buf = buffer;
		if (buf.length < size) buf.resize(size);
		buf.rewind();
		for (i in 0 ... size) buf.writeByte(d[i]);
		buf.savePart(path, 0, size);
	}
	#else
	public static inline function getBytes(path:String):Bytes {
		return Bytes.ofData(Buffer.load(path));
	}
	public static inline function saveBytes(path:String, bytes:Bytes):Void {
		bytes.getData().save(path);
	}
	#end
	
	@:access(sys.io.FileInput.new)
	public static inline function read(path:String, binary:Bool = true):FileInput {
		return new FileInput(path);
	}
	
	@:access(sys.io.FileOutput.new)
	public static inline function write(path:String, binary:Bool = true):FileOutput {
		return new FileOutput(path);
	}
	
	#if !sfgml_native_bytes
	@:access(sys.io.FileOutput.new)
	@:access(haxe.io.Output.data)
	@:access(haxe.io.Output.dataLen)
	@:access(haxe.io.Output.dataPos)
	public static function append(path:String, binary:Bool = true):FileOutput {
		var out = new FileOutput(path);
		var d = getBytesData(path);
		var p = d.length;
		out.data = d;
		out.dataLen = p;
		out.dataPos = p;
		return out;
	}
	
	@:access(sys.io.FileOutput.new)
	@:access(haxe.io.Output.data)
	@:access(haxe.io.Output.dataLen)
	@:access(haxe.io.Output.dataPos)
	public static function update(path:String, binary:Bool = true):FileOutput {
		var out = new FileOutput(path);
		var d = getBytesData(path);
		var p = d.length;
		out.data = d;
		out.dataLen = p;
		out.dataPos = p;
		return out;
	}
	#else
	
	#end
	
	public static inline function copy(src:String, dst:String):Void {
		raw("file_copy")(src, dst);
	}
}
