actions
withClientDo: aBlock
	"Evaluates aBlock using one of the 
	(at the moment) idle clients as parameter.
	Other code could reach the client in use by accessing
	the XXCurrentClient dynamic variable's value."

	| client |

	client := self requestClient.
		
	^ self currentClientDynamicVariable value: client during:[
		[aBlock value: client] ensure:[
			self returnClient: client]]
