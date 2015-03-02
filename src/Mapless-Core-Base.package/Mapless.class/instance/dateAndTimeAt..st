actions
dateAndTimeAt: aSelector

	| value |
	
	value := self at: aSelector.
	
	value isString ifTrue: [ ^ DateAndTime fromString: value ].
	
	value isDictionary ifTrue: [ ^ DateAndTime fromUnixTime: (value at: '$date') / 1000 ].
	
	^ nil 