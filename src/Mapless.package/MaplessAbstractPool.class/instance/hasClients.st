testing
hasClients
	"Answers true if this pool has at least one client"
	^ self hasIdleClients or:[
	self hasBusyClients]