accessing
doesNotUnderstand: aMessage
	"The idea behind this DNU is to use the selector as setters or getter 
	delegating to data (aJsonObject)"
	
	| key |
	
	key := aMessage selector.

	key isUnary ifTrue: [ ^ self data at: key asString ].

	^ (key isKeyword and: [ ( key occurrencesOf: $: ) = 1] )
		ifTrue: [ key := key allButLast asSymbol.
				self data at: key asString put: aMessage arguments first ]
		ifFalse: [ super doesNotUnderstand: aMessage ]
				
	