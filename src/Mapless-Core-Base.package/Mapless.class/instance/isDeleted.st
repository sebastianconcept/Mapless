testing
isDeleted

	| isDeleted |
	
	isDeleted  := self data at: 'isDeleted'.
	^ isDeleted notNil and: [ isDeleted ]