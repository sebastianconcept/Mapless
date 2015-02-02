actions
asNoSQLValue: aMapless
	"Answers this aggregate as value you will expect to have in a noSQL storage"

	| bsonFriendly |
	
	[bsonFriendly := self asMongoDocumentFor: aMapless data] ifCurtailed:[
		aMapless data removeKey: '_id' ifAbsent: [ nil ] ] .
		
	^ self stringify: (BSON write: bsonFriendly) 