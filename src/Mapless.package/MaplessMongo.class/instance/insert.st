actions
insert
	
	| bsonFriendly |
		
	self onAboutToInsert.

	[ bsonFriendly := self asMongoDocument ] ifCurtailed: [
		self data removeKey: self class idAttribute ifAbsent: [ nil ] ] .

	self class databaseCollection add: bsonFriendly.
	
	self onInserted
