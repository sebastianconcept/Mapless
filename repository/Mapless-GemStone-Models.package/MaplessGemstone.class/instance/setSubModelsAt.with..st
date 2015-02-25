actions
setSubModelsAt: aKey with: anObject 
	| modelClass newSubModel |
	
	"one submodel"
	(((anObject isKindOf: JsonObject) or:[
	anObject isKindOf: OrderedJsonObject]) and:[
	anObject includesKey: 'modelClass']) ifTrue:[ 
		modelClass := Smalltalk 
						at: (anObject at: 'modelClass') asSymbol    
						ifAbsent:[self error: 'Could not find that class'].
		newSubModel := modelClass fromJSONObject: anObject.
		newSubModel setSubModels.
		self data at: aKey put: newSubModel].
	
	"many submodels"
	((anObject isKindOf: Collection) and:[
	anObject anySatisfy:[:e| 
		(self isReifiedJSON: e) and:[
		e includesKey: 'modelClass' ]]]) ifTrue:[|newSubModels|
			newSubModels := anObject collect:[:each|
				modelClass := Smalltalk 
						at: (each at: 'modelClass') asSymbol    
						ifAbsent:[self error: 'Could not find that class'].
					newSubModel := modelClass fromJSONObject: each.
					newSubModel setSubModels].
			self data at: aKey put: newSubModels]