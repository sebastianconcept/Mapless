accessing
model
	^ model ifNil: [ self initializeModel ]