actions
purgeUnavailable
	"Removes any client that might be expired or unreacheable."
	
	self busyClients copy do:[ :e | self ifUnavailablePurge: e ].
	self idleClients copy do:[ :e | self ifUnavailablePurge: e ]