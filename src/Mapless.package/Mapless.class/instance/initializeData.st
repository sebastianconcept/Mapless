accessing
initializeData

	^ raw 
		ifNil:[data := OrderedJsonObject new]
		ifNotNil:[data := Json readFrom: raw readStream]