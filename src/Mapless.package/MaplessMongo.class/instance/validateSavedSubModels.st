actions
validateSavedSubModels
	"Navigates this instance's content in search of unsaved sub models
	and complain about it."
	
	self data values do:[ :e |
		(e isKindOf: MaplessReference) ifTrue:[
			e isUnsaved
				ifFalse: [ e validateSavedSubModels ]
				ifTrue:[MaplessUnsavedSubmodel signal: 'This sub model is unsaved. You need to save all sub models before saving a composed model' ] ] ]