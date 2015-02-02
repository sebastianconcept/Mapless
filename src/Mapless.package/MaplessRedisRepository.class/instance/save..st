actions
save: aMapless
	"Storage this instance into the persistent collection"
		
	self onAboutToSave: aMapless.

	self database
		set: aMapless oid 
		value: (self asNoSQLValue: aMapless).
		
	self onSaved: aMapless