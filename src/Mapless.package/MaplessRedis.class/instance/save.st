actions
save
	"Storage this instance into the persistent collection"
		
	self onAboutToSave.

	self class client 
		set: self oid 
		value: self asNoSQLValue.
		
	self onSaved