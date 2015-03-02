actions
remove: aClient

	self idleClients remove: aClient ifAbsent:[ nil ].
	self busyClients remove: aClient ifAbsent:[ nil ].
	