accessing
doesNotUnderstand: aMessage
	"The idea behind this DNU is to use the selector as setters or getter 
	delegating to data (aJsonObject). 
	The mongo model specialization will store sub mongo models wrapped
	in references so serialization and save order is conveniently done."
	
	| key part |

	key := aMessage selector.
	key isUnary ifTrue: [ ^ super doesNotUnderstand: aMessage ].

	^ (key isKeyword and: [(key occurrencesOf: $:) = 1])
		ifTrue: [
			key := key allButLast asSymbol.
			part := aMessage arguments first.
			" We don't always want to have a mapless reference as submodel.
			Some times we actually want a mapless itself!
			(part isKindOf: MaplessMongoModel) ifTrue:[
				part := part asMaplessReference ]." 
			self data at: key asString put: part]
		ifFalse: [super doesNotUnderstand: aMessage]
				
	