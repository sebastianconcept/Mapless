actions
delete: aMapless
	"Saves this instance as deleted in the persistent collection"

	self onBeforeDelete: aMapless.
	
	aMapless beDeleted.
	
	self save: aMapless.
	
	self onAfterDelete: aMapless