actions
returnClient: aClient
	"Sends aClient to go from the busy ones to the idle ones
	but only if it's still valid"

	self clientsMutex critical:[
	
		self busyClients remove: aClient ifAbsent: [self returningUnusedClient].		
	
		aClient isValid ifTrue:[
			self idleClients add: aClient] ]