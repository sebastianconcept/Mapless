actions
requestClient
	"Answers a aClient instance taken from the idle clients.
	It'll create a new one if needed.
	It's a thread safe operation."

	^ self clientsMutex
		critical: [ | client |
			client := self hasIdleClients
				ifTrue: [ self idleClients anyOne ]
				ifFalse: [ self makeClient ].
			(client notNil and: [ client isValid not ])
				ifTrue: [ self remove: client.
					client := self makeClient ].
			self idleClients remove: client ifAbsent: [ nil ].
			client ifNotNil: [ self busyClients add: client ].

			client ]