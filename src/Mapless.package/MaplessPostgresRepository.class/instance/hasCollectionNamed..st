testing
hasCollectionNamed: aCollectionName
	"Answers true if a table named aCollectionName exists in the postgres database.
	False otherwise."
	
	^ database do: [ :pg | | result |
		result := pg execute: 'SELECT EXISTS (
			SELECT * FROM pg_tables WHERE
	tablename = ''',aCollectionName,''');'.

		result rows notEmpty and: [ 
		result rows first data first ] ]