package gml.events;

/**
 * ...
 * @author YellowAfterlife
 */
@:std @:dsMap
typedef HTTPEvent = {
	var id:gml.net.HTTP;
	var status:HTTPEventStatus;
	var url:String;
	
	/** Result string. Only present on Success */
	@:optional var result:String;
	
	/** HTTP status code */
	@:native("http_status") var httpStatus:Int;
	
	/** Expected size during Progress event. Can be -1 if unknown */
	@:optional var contentLength:Int;
	
	/** Amount of data downloaded as of yet (in Progress)*/
	@:optional var sizeDownloaded:Int;
}
enum abstract HTTPEventStatus(Int) from Int to Int {
	var Success = 0;
	var Failure = -1;
	var Progress = 1;
}
