actions
makeClient
	"Returns a new client so it can be (re)used in the pool"

	^ MongoAPI default 
		open;
		yourself 