package gml.net;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("network_socket") @:snakeCase
@:std extern enum abstract SocketType(Int) {
	var TCP;
	var UDP;
	var Bluetooth;
	var TCP_PSN;
	var UDP_PSN;
	var UDP_Switch;
	@:native("ws") var WebSocket;
}