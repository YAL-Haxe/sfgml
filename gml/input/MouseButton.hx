package gml.input;

enum abstract MouseButton(Int) from Int to Int {
	var MbAny = -1;
	var MbNone = 0;
	var MbLeft = 1;
	var MbRight = 2;
	var MbMiddle = 3;
}
