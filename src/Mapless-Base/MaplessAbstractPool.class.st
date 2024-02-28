"
This is the abstraction that Mapless uses to have pools of clients to the database connections.
See subclasses for concrete accessors.
"
Class {
	#name : #MaplessAbstractPool,
	#superclass : #Object,
	#instVars : [
		'hostname',
		'port',
		'username',
		'password'
	],
	#category : #'Mapless-Base-Repositories'
}

{ #category : #'instance creation' }
MaplessAbstractPool class >> local [
	^ self subclassResponsibility
]

{ #category : #accessing }
MaplessAbstractPool >> currentClientDynamicVariableClass [
	"Answers the class of the dynamic variable that will
	hold the value of the current client during the evaluation of its usage."

	^ self subclassResponsibility
]

{ #category : #accessing }
MaplessAbstractPool >> hostname [
	^ hostname
]

{ #category : #accessing }
MaplessAbstractPool >> hostname: anObject [
	hostname := anObject
]

{ #category : #testing }
MaplessAbstractPool >> isUsingAuth [
	^ username notNil
		and: [ password notNil
				and: [ username notEmpty and: [ password notEmpty ] ] ]
]

{ #category : #actions }
MaplessAbstractPool >> logNewClient: mongoClient [
	Stdio stderr
		lf;
		<< ('Created mongo client ' , mongoClient printString);
		flush
]

{ #category : #accessing }
MaplessAbstractPool >> password [
	^ password
]

{ #category : #accessing }
MaplessAbstractPool >> password: anObject [
	password := anObject
]

{ #category : #accessing }
MaplessAbstractPool >> port [
	^ port
]

{ #category : #accessing }
MaplessAbstractPool >> port: anObject [
	port := anObject
]

{ #category : #accessing }
MaplessAbstractPool >> username [
	^ username
]

{ #category : #accessing }
MaplessAbstractPool >> username: anObject [
	username := anObject
]
