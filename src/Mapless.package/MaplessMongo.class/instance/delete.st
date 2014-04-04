actions
delete
	"Saves this instance as deleted in the persistent collection"
	
	self onAboutToDelete.
	
	self beDeleted; save.
	
	self onDeleted 
