actions
reset 

	self busyClients copy do:[ :e | 
		e reset. 
		self remove: e ].

	self idleClients copy do:[ :e | 
		e reset.
		self remove: e ].