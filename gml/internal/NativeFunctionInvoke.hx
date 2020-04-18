package gml.internal;

class NativeFunctionInvoke {
	public static function call(fn:Dynamic, args:Array<Dynamic>, ?argc:Int):Dynamic {
		if (argc == null) argc = args.length;
		if (argc > maxArgs) throw "Too many arguments!";
		return funcs[argc](fn, args);
	}
	
	static inline var maxArgs:Int = 32;
	static var funcs:Array<(fn:Dynamic, args:Array<Dynamic>)->Dynamic> = [
		function with0(fn:Dynamic, w:Array<Dynamic>) return fn(),
		function with1(fn:Dynamic, w:Array<Dynamic>) return fn(w[0]),
		function with2(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1]),
		function with3(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2]),
		function with4(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3]),
		function with5(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4]),
		function with6(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5]),
		function with7(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6]),
		function with8(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7]),
		function with9(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8]),
		function with10(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9]),
		function with11(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10]),
		function with12(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11]),
		function with13(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12]),
		function with14(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13]),
		function with15(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14]),
		function with16(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]),
		function with17(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16]),
		function with18(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17]),
		function with19(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18]),
		function with20(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19]),
		function with21(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20]),
		function with22(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21]),
		function with23(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21],w[22]),
		function with24(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21],w[22],w[23]),
		function with25(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21],w[22],w[23],w[24]),
		function with26(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21],w[22],w[23],w[24],w[25]),
		function with27(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21],w[22],w[23],w[24],w[25],w[26]),
		function with28(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21],w[22],w[23],w[24],w[25],w[26],w[27]),
		function with29(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21],w[22],w[23],w[24],w[25],w[26],w[27],w[28]),
		function with30(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21],w[22],w[23],w[24],w[25],w[26],w[27],w[28],w[29]),
		function with31(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21],w[22],w[23],w[24],w[25],w[26],w[27],w[28],w[29],w[30]),
		function with32(fn:Dynamic, w:Array<Dynamic>) return fn(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21],w[22],w[23],w[24],w[25],w[26],w[27],w[28],w[29],w[30],w[31]),
	];
}
/* autogen:
var r = "";
for (var i = 0; i <= 32; i++) {
	r += "\t\tfunction with"+i+"(fn:Dynamic, w:Array<Dynamic>) return fn(";
	for (var k = 0; k < i; k++) {
		if (k > 0) r += ",";
		r += "w[" + k + "]";
	}
	r += "),\n";
}
*/