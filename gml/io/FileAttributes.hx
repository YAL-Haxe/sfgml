package gml.io;

@:native("fa") @:snakeCase
@:std extern enum abstract FileAttributes(Int) from Int to Int {
	var None;
	@:native("readonly") var ReadOnly;
	var Hidden;
	@:native("sysfile") var SysFile;
	@:native("volumeid") var VolumeID;
	var Directory;
	var Archive;
}