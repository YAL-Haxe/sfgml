package gml.internal;
import SfTools.raw;

class NativeConstructorInvoke {
	public static function call(ctr:Dynamic, args:Array<Dynamic>, ?argc:Int):Dynamic {
		if (argc == null) argc = args.length;
		if (argc > maxArgs) throw "Too many arguments!";
		return funcs[argc](ctr, args);
	}
	
	static inline var maxArgs:Int = 32;
	static var funcs:Array<(ctr:Dynamic, args:Array<Dynamic>)->Dynamic> = [
		function with0(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(),
		function with1(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0]),
		function with2(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1]),
		function with3(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2]),
		function with4(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3]),
		function with5(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4]),
		function with6(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5]),
		function with7(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6]),
		function with8(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7]),
		function with9(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8]),
		function with10(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9]),
		function with11(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10]),
		function with12(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11]),
		function with13(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12]),
		function with14(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13]),
		function with15(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14]),
		function with16(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]),
		function with17(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16]),
		function with18(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17]),
		function with19(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18]),
		function with20(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19]),
		function with21(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20]),
		function with22(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21]),
		function with23(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21],w[22]),
		function with24(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21],w[22],w[23]),
		function with25(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21],w[22],w[23],w[24]),
		function with26(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21],w[22],w[23],w[24],w[25]),
		function with27(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21],w[22],w[23],w[24],w[25],w[26]),
		function with28(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21],w[22],w[23],w[24],w[25],w[26],w[27]),
		function with29(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21],w[22],w[23],w[24],w[25],w[26],w[27],w[28]),
		function with30(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21],w[22],w[23],w[24],w[25],w[26],w[27],w[28],w[29]),
		function with31(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21],w[22],w[23],w[24],w[25],w[26],w[27],w[28],w[29],w[30]),
		function with32(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],w[20],w[21],w[22],w[23],w[24],w[25],w[26],w[27],w[28],w[29],w[30],w[31]),
	];
}
/* autogen:
var r = "";
for (var i = 0; i <= 32; i++) {
	r += "\t\tfunction with"+i+'(ctr:Dynamic, w:Array<Dynamic>) return raw("new {0}", ctr)(';
	for (var k = 0; k < i; k++) {
		if (k > 0) r += ",";
		r += "w[" + k + "]";
	}
	r += "),\n";
}
*/