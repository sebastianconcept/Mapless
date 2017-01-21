testing
isUnsaved: aMapless
	"Answer true if this instance was not saved yet.
	Note: we assume that if aMapless does not have an id 
	then is because the application never used the backend to saved it."

	^ (self idOf: aMapless) isNil and: [ 
	aMapless id isNil ]