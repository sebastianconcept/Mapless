actions
ifUnavailablePurge: aMongoClient
	"Tests aMongoClient and remove it from this pool if invalid."

	(aMongoClient isOpen not or:[
	([aMongoClient databases first collections.
	true] on: Error do: [:x| false]) not ] ) ifTrue:[ self remove:  aMongoClient]