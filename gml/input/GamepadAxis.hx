package gml.input;

@:enum abstract GamepadAxis(Int) from Int to Int {
	var LX = 0x8011;
	var LY = 0x8012;
	var RX = 0x8013;
	var RY = 0x8014;
}
