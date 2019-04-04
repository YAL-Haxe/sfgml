package;
#if (macro)
@:coreType @:runtimeValue abstract Class<T> { }
#else
import gml.MetaType;
@:keep @:forward @:runtimeValue @:remove
abstract Class<T>(MetaClass<T>)
	from MetaClass<T> to MetaClass<T>
	to MetaType<T> {
	
}
#end
