accessing
id
	"Answers the server-side assigned id of this mapless.
	Note: the expectation is to have this id set when is saved/inserted 
	for the first time into a repo."
	
	^ self data at: (self currentRepository 
						ifNil: [ nil ] 
						ifNotNil: [ :repo | repo idAttribute ] )