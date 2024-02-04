Extension { #name : #SampleTask }

{ #category : #'*Mapless-Redis-Core' }
SampleTask class >> getPubsubRepository [

	^ MaplessRedisHelper repository
]
