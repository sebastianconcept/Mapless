initialization
initializeModel 
	"Note this reference will load the model from the database only once,
	usually in the first message send"
	
	model := self getMongoModel.
	
	(model notNil and:[
	model isUnsaved not]) ifTrue:[
		oid := model oid ].
	
	^ model
