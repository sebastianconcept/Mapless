accessing
subModelAt: aSelector
	"Answers the reified submodel (instantiating if necessary)."
	
	| subModelData class |

	subModelData := self data at: aSelector.
	subModelData ifNil:[^nil].

	"legacy code from Amber's json serialization
	subModelData := subModelData at: '@data'.
	subModelData ifNil:[^ FlowModelDataError signal: 'Cannot find ', aSelector,'''s data']."
	
	class := subModelData at: 'class'.
	class := Smalltalk at: class asSymbol ifAbsent:[
		MaplessModelMetadataError signal: 'Cannot find ',aSelector,'''s metadata'].
	
	^ class fromReified: subModelData	