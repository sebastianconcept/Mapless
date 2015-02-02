accessing
id

	^ self data at: (self currentRepository ifNil: [ '_id' ] ifNotNil: [ :p | p idAttribute ] )