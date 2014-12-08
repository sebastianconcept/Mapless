initialization
initializeModel 
	"Note this reference will load the model from the database only once,
	usually in the first message send"
	
	self flag: #todo.
	"sas: this should be improved to decouple this guy from the specific strategy needed for model retrieve.
	Can a dynamic variable help in deciding what's the strategy to get the model?
	So if you're using Redis go a Redis get, if using Mongo a Mongo get, ditto with Postgres"
	
	model := self getMongoModel.
	
	(model notNil and:[
	model isUnsaved not]) ifTrue:[
		oid := model oid ].
	
	^ model
