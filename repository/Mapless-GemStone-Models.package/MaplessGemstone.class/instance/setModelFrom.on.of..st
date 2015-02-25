actions
setModelFrom: aJsonString on: aKey of: aJsonObject
	"Set model (only if someJsonStrings feels like those)"

	| json modelClass newSubModel |

	json := Json readFrom: aJsonString readStream.	
	modelClass := Smalltalk 
						at: (json at: 'modelClass') asSymbol
						ifAbsent:[self error: 'Cannot find that class'].
							
	newSubModel :=  modelClass fromJSONObject: json.

	newSubModel setSubModels.
	
	 aJsonObject 
		at: aKey 
		put: newSubModel