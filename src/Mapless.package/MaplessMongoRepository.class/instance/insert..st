actions
insert: aMapless
	
	| bsonFriendly |
		
	self onBeforeInsert: aMapless.

	[ bsonFriendly := (self asMongoDocumentFor: aMapless data) ] ifCurtailed: [
		aMapless data removeKey: self idAttribute ifAbsent: [ nil ] ] .

	(self databaseCollectionNamed: aMapless class name asString) add: bsonFriendly.

	self onAfterInsert: aMapless
