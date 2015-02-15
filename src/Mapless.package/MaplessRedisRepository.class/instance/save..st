actions
save: aMapless
	"Storage this instance into the persistent collection"
		
	self onBeforeSave: aMapless.

	self database
		set: aMapless oid 
		value: (self asNoSQLValue: aMapless).
		
	self onAfterSave: aMapless