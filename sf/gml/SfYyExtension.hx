package sf.gml;

/**
 * ...
 * @author YellowAfterlife
 */
typedef SfYyExtension = {> SfYyExtNode,
	var name:String;
	var date:String;
	var license:String;
	var version:String;
	var productID:String;
	var packageID:String;
	var files:Array<SfYyExtFile>;
}

typedef SfYyExtFile = {> SfYyExtNode,
	var constants:Array<SfYyExtMacro>;
	var functions:Array<SfYyExtFunc>;
	var init:String;
	//var final:String;
	var filename:String;
	var origname:String;
	var order:Array<SfYyGUID>;
	var kind:Int;
	var uncompress:Bool;
}

typedef SfYyExtMacro = {> SfYyExtNode,
	// 2.2
	var ?constantName:String;
	// 2.3
	var ?name:String;
	var hidden:Bool;
	var value:String;
}

typedef SfYyExtFunc = {> SfYyExtNode,
	var name:String;
	var externalName:String;
	var help:String;
	var hidden:Bool;
	var argCount:Int;
	var returnType:Int;
	var args:Array<Int>;
	var kind:Int;
}

typedef SfYyExtNode = {
	// 2.2:
	var ?id:SfYyGUID;
	var ?modelName:String;
	var ?mvc:String;
	// 2.3:
	var ?resourceType:String;
	var ?resourceVersion:String;
	var ?tags:Array<String>;
}

abstract SfYyGUID(String) {
	static function create() {
		var result = "";
		for (j in 0 ... 32) {
			if (j == 8 || j == 12 || j == 16 || j == 20) {
				result += "-";
			}
			result += "0123456789abcdef".charAt(Math.floor(Math.random() * 16));
		}
		return result;
	}
	public inline function new() {
		this = create();
	}
}
