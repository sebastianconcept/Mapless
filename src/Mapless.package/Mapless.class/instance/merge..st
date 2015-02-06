actions
merge: aMapless
	"Merge the contents of this mapless instance with the contents in aMapless.
	It will NOT resolve merge conflicts or anything smart.
	It's just adding the missing parts.
	It does it deep, though."
	
	(aMapless data keys asOrderedCollection 
		removeAllFoundIn: aMapless class keysToExclude;
		yourself) do: [ :aKey | | part |
			part := aMapless perform: aKey asSymbol.
			(part isKindOf: Mapless) ifTrue: [ |subMaplessOrNil|
				subMaplessOrNil := self perform: aKey asSymbol.
				subMaplessOrNil ifNotNil: [ subMaplessOrNil merge: part ] ].
			self data at: aKey ifAbsentPut: [ part ] ]