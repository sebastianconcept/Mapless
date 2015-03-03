actions
update: aMapless

	self onBeforeUpdate: aMapless.
	
	self basicUpdate: (self storableFor: aMapless data).
		
	self onAfterUpdate: aMapless