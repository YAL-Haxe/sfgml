package gml.input;

@:enum abstract GamepadButton(Int) from Int to Int {
	var Face1 = 0x8001;
	var Face2 = 0x8002;
	var Face3 = 0x8003;
	var Face4 = 0x8004;
	var ShoulderL = 0x8005;
	var ShoulderR = 0x8006;
	var TriggerL = 0x8007;
	var TriggerR = 0x8008;
	var Select = 0x8009;
	var Start = 0x800A;
	var StickL = 0x800B;
	var StickR = 0x800C;
	var PadU = 0x800D;
	var PadD = 0x800E;
	var PadL = 0x800F;
	var PadR = 0x8010;
}
