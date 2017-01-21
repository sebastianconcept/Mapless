accessing
id
	"Answers the server-side assigned id of this mapless.
	Note: the expectation is to have this id set when is saved/inserted 
	for the first time into a repo. A second important expectation is that
	different repositories might use different names to store their 'id'
	for example MongoDB uses '_id' and Postgres uses 'oid' and others
	might use variations that should get normalized into 'id'."
	
	^ self data at: 'id'