actions
insert
		
	self onAboutToInsert.

	self class databaseCollection at: self oid put: self.
	
	self onInserted