actions
setSubModelsAt: aKey with: anObject 

	((anObject isKindOf: JsonObject) and:[
	anObject includesKey: 'modelClass']) ifTrue:[ | modelClass newSubModel |
		modelClass := Smalltalk 
						at: (anObject at: 'modelClass') asSymbol    
						ifAbsent:[self error: 'Could not find that class'].
		newSubModel := modelClass fromJSONObject: anObject.
		newSubModel setSubModels.
		data at: aKey put: newSubModel]