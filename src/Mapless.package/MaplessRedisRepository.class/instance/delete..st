actions
delete: aMapless
	"Removes this instance from the repository"

	self onBeforeDelete: aMapless.
	
	aMapless beDeleted.
	
	self save: aMapless.
	
	self onAfterDelete: aMapless