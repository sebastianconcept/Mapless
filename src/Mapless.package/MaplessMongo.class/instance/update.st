actions
update

	| bsonFriendly |
	
	bsonFriendly := self asMongoDocument.

	self onAboutToUpdate.

	self class databaseCollection 
		replace:  (Dictionary new 
					at: self class idAttribute put: self id;
					yourself)
		with: bsonFriendly.
		
	self onUpdated.