actions
insert: aMapless
	
	| bsonFriendly |
		
	self onAboutToInsert: aMapless.

	[ bsonFriendly := (self asMongoDocumentFor: aMapless data) ] ifCurtailed: [
		aMapless data removeKey: self idAttribute ifAbsent: [ nil ] ] .

	(self databaseCollectionNamed: aMapless class name asString) add: bsonFriendly.

	self onInserted: aMapless
