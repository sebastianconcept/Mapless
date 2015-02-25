accessing
data

	^ data ifNil: [ self initializeData ]