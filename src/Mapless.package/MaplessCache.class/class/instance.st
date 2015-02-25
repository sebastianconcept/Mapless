accessing
instance

	^ instance ifNil:[ self initializeInstance ]