actions
delete: aMapless
	"Saves this instance as deleted in the persistent collection"

	self onAboutToDelete: aMapless.
	
	aMapless beDeleted.
	
	self save: aMapless.
	
	self onDeleted: aMapless