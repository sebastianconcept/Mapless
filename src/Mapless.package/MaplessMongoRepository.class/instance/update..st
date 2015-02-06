actions
update: aMapless

	| bsonFriendly |

	self onBeforeUpdate: aMapless.
	
	bsonFriendly := self asMongoDocumentFor: aMapless data.

	(self databaseCollectionNamed: aMapless class name asString)
		replace:  (Dictionary new 
					at: aMapless class idAttribute put: aMapless id;
					yourself)
		with: bsonFriendly.
		
	self onAfterUpdate: aMapless