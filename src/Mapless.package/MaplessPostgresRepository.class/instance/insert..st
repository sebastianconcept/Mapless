actions
insert: aMapless
	
	| bsonFriendly |

	self onBeforeInsert: aMapless.

	[ bsonFriendly := (self storableFor: aMapless data) ] ifCurtailed: [
		aMapless data removeKey: self idAttribute ifAbsent: [ nil ] ].

	self ensureCollectionNamed: aMapless class name asString.
	self basicInsert: bsonFriendly. 

	self onAfterInsert: aMapless
