package gml.sys;

/**
 * ...
 * @author YellowAfterlife
 */
enum abstract SystemType(Int) from Int to Int {
	var Unknown = -1;
	var Windows = 0;
	var MacOSX = 1;
	var iOS = 3;
	var Android = 4;
	var Linux = 6;
	var WinPhone = 7;
	var Tizen = 8;
	var PSVita = 12;
	var PS4 = 14;
	var XBoxOne = 15;
	var PS3 = 16;
	var XBox360 = 17;
	var UWP = 18;
	var TVOS = 20;
	var Switch = 21;
}
