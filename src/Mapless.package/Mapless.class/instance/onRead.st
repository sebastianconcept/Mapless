reactions
onRead
	"This model has been readed.
	All inst var values that are expected to be model objects, need to be re-instanciated."

	self data keys do:[:key| |value|
		value := self data at: key.
		value isPersistentModel ifTrue:[
			value := value fresh.
			self at: key put: value]].
	