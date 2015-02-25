accessing
session

	^ session ifNil:[ self initializeSession ]