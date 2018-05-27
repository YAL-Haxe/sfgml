package gml.sys;

/**
 * ...
 * @author YellowAfterlife
 */
@:std @:enum abstract BrowserType(Int) from Int to Int {
	var None = -1;
	var Unknown = 0;
	var IE = 1;
	var Firefox = 2;
	var Chrome = 3;
	var Safari = 4;
	var SafariMobile = 5;
	var Opera = 6;
	var AndroidWebkit = 7;
	var WindowsStore = 8;
	var Tizen = 9;
	var IEMobile = 10;
	var Edge = 11;
}
