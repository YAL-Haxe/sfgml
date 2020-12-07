package gml.sys;

/**
 * ...
 * @author YellowAfterlife
 */
@:std @:snakeCase @:native("browser")
extern enum abstract BrowserType(Int) from Int to Int {
	@:native("not_a_browser") var None;
	var Unknown;
	var IE;
	var Firefox;
	var Chrome;
	var Safari;
	var SafariMobile;
	var Opera;
	var WindowsStore;
	var Tizen;
	@:native("ie_mobile") var IEMobile;
	var Edge;
}

