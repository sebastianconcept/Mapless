Extension { #name : #Mapless }

{ #category : #'*Mapless-Redis-Core' }
Mapless class >> getPubsubRepository [

	"Answer the MaplessRedisRepository that has clients in subscribed state.
	For details on why see:
	https://github.com/mumez/RediStick/issues/30#issuecomment-1921325275
	https://redis.io/commands/subscribe/"

	self subclassResponsibility
]
