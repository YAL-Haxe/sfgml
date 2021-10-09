package gml.input;

@:docName("gamepad_button")
@:native("gp") @:snakeCase
extern enum abstract GamepadButton(Int) from Int to Int {
	var Face1;
	var Face2;
	var Face3;
	var Face4;
	@:native("shoulderl") var ShoulderL;
	@:native("shoulderr") var ShoulderR;
	@:native("shoulderlb") var TriggerL;
	@:native("shoulderrb") var TriggerR;
	var Select;
	var Start;
	@:native("stickl") var StickL;
	@:native("stickr") var StickR;
	@:native("padu") var PadU;
	@:native("padd") var PadD;
	@:native("padl") var PadL;
	@:native("padr") var PadR;
}
