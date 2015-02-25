accessing
asBSONFriendly

	^ Dictionary new 
		at: 'key' put: self id;
		at: 'value' put: self asNoSQLValue;
		yourself