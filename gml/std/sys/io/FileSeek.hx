package sys.io;

/**
 * ...
 * @author YellowAfterlife
 */
@:enum abstract FileSeek(Int) from Int to Int to gml.io.BufferSeek {
	var SeekBegin = 0;
	var SeekCur = 1;
	var SeekEnd = 2;
}
