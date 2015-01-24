actions
ensureId 
	"Makes sure this mapless has stamped a backend side id."
	
	self hasId ifFalse: [
		self id: self class getNewId ].