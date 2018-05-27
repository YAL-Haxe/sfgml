package gml.net;

/**
 * ...
 * @author YellowAfterlife
 */
@:enum abstract SocketType(Int) from Int to Int {
	
	/** */
	var TCP = 0;
	
	/** */
	var UDP = 1;
	
	/** Bluetooth (not implemented) */
	var BT = 2;
	
	/** PSN-specific TCP */
	var PSNTCP = 3;
	
	/** PSN-specific UDP */
	var PSNUDP = 4;
	
	/** WebSocket (GMS 2.2+) */
	var WS = 5;
}
