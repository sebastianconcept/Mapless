actions
ensureOID

	super ensureId.
	
	self hasOID ifFalse:[
		self data at: '_id' put: self id]