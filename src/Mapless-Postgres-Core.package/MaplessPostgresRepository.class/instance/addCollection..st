actions
addCollection: aCollectionName

	^ database do: [ :pg |
		pg execute: 'CREATE TABLE "',aCollectionName,'" (
			key varchar(36) PRIMARY KEY, 
			value json);' ]