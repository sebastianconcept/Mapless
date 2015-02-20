testing
hasCollectionNamed: aCollectionName

	^ database do: [ :pg | | result |
		result := pg execute: 'SELECT to_regclass(''public.',aCollectionName,''');'.
		result rows notEmpty and: [ 
		result rows first data first notNil ]]