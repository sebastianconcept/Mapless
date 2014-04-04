initialization
initialize

	super initialize.
	
	self ensureId.
	
	"We include the class name so we have the minimal metadata at consuming time"
	self modelClass: self class name.
	self createdOn: DateAndTime now.
