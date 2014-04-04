accessing
asNoSQLValue
	"Answers this aggregate as value you will expect to have in a noSQL storage"

	| bsonFriendly |
	
	[bsonFriendly := self asMongoDocument] ifCurtailed:[
		self data removeKey: '_id' ifAbsent: [ nil ] ] .
		
	^ self class stringify: (BSON write: bsonFriendly) 