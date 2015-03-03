accessing
asDictionary 
	"Answers this instance as a JSON friendly dictionary"
	
	^ [:dic| | attributes |
		attributes := OrderedJsonObject new.
		dic at: self class name asString put: attributes.
		self data associationsDo:[:assoc|
			assoc value isPersistentModel 
				ifTrue:[ attributes at: assoc key put: assoc value asDictionary ]
				ifFalse:[ attributes at: assoc key put: assoc value] ].
		dic ] value: OrderedJsonObject new