actions
update

	| bsonFriendly |
	
	bsonFriendly := self asMongoDocument.

	self onAboutToUpdate.

	self class databaseCollection 
		replace:  (Dictionary new 
					at: '_id' put: self oid;
					yourself)
		with: bsonFriendly.
		
	self onUpdated.