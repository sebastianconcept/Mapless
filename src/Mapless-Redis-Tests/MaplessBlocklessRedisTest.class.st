Class {
	#name : #MaplessBlocklessRedisTest,
	#superclass : #MaplessRedisTest,
	#category : #'Mapless-Redis-Tests'
}

{ #category : #actions }
MaplessBlocklessRedisTest >> newRepository [
	| accessor |
	accessor := MaplessBlocklessRedisPool local.
	accessor start.
	accessor auth: 'my_password'.
	^ MaplessRedisRepository
		for: self class databaseIndex
		with: accessor
		using: MaplessTrivialResolver new
]
