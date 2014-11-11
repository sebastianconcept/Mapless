initialization
initializeOn: aJsonObject

	super initialize.
	
	data := aJsonObject.
	
	self ensureId.
	
	"We include the class name so we have the minimal metadata at consuming time"
	self modelClass ifNil:[
		self modelClass: self class name].

	self createdOn ifNil:[
		self createdOn: DateAndTime now].
