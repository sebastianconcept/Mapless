actions
insert
	
	| bsonFriendly |
		
	self onAboutToInsert.

	[bsonFriendly := self asMongoDocument] ifCurtailed:[
		self data removeKey: '_id' ifAbsent: [ nil ] ] .

	self class databaseCollection add: bsonFriendly.
	
	self onInserted
