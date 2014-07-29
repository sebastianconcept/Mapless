initialization
initializeOn: aJsonObject

	super initialize.
	
	data := aJsonObject.
	
	"We include the class name so we have the minimal metadata at consuming time"
	self modelClass ifNil:[
		self modelClass: self class name].
