accessing
models

	^ models ifNil:[ self initializeModels ]