actions
asJsonObject 

	"The only valid scenario when this won't have an oid 
	is when it wraps an unsaved submodel"
	oid ifNil:[ oid := model oid ].

	"a nil oid at this point should never happen"	
	oid ifNil:[^ MaplessUnsavedSubmodel signal: 'This sub model is unsaved. You need to save all sub models before saving a composed model'].
	self assert: oid notNil.

	^ JsonObject new
		at: 'modelClass' put: modelClass;
		at: 'oid' put: oid;
		yourself