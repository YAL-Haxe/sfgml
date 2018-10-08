package gml.layers;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("layer.element") extern class LayerElement {
	
	//
	public var elementType(get, never):LayerElementType;
	@:expose("layer_get_element_type") private function get_elementType():LayerElementType;
	
	//
	public var parentLayer(get, never):Layer;
	@:expose("layer_get_element_layer") private function get_parentLayer():Layer;
}
