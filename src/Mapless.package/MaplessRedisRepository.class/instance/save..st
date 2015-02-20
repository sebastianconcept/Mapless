actions
save: aMapless
	"Storage this instance into the persistent collection"

	| bsonFriendly |
			
	self onBeforeSave: aMapless.

	[ bsonFriendly := self storableFor: aMapless data ] ifCurtailed:[
		aMapless data removeKey: self idAttribute ifAbsent: [ nil ] ] .

	self database
		set: (self idOf: aMapless) 
		value: (self asRedisValue: bsonFriendly).
		
	self onAfterSave: aMapless