actions
update: aMapless

	| bsonFriendly |
	
	bsonFriendly := self asMongoDocumentFor: aMapless data.

	self onAboutToUpdate: aMapless.

	(self databaseCollectionNamed: aMapless class name asString)
		replace:  (Dictionary new 
					at: aMapless class idAttribute put: aMapless id;
					yourself)
		with: bsonFriendly.
		
	self onUpdated: aMapless