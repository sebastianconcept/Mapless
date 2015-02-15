actions
asJsonObject 

	"The only valid scenario when this won't have an id 
	is when it wraps an unsaved submodel"
	id ifNil: [ id := model id ].

	"a nil id at this point should never happen"	
	id ifNil: [ ^ MaplessUnsavedSubmodel signal: 'This sub model is unsaved. You need to save all sub models before saving a composed model' ].
	self assert: id notNil.

	^ JsonObject new
		at: 'modelClass' put: modelClass;
		at: MaplessCurrentRepository value idAttribute put: id;
		yourself