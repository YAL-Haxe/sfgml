package gml.io;

/**
 * Options used in Buffer:seek
 * @author YellowAfterlife
 */
@:native("buffer_seek") @:snakeCase
@:std extern enum abstract BufferSeek(Int) from Int to Int {
	var Start    ; // = 0;
	var Relative ; // = 1;
	var End      ; // = 2;
}
