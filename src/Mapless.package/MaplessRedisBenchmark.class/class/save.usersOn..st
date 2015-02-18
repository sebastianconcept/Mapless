actions
save: aQuantity usersOn: aStream 

	| guy user firstNames lastNames users delay savesPerSecond readsPerSecond redisRepository |

	firstNames := OrderedCollection new.
	lastNames := OrderedCollection new.
	users := OrderedCollection new.
	redisRepository := MaplessRedisRepository on: RedisPool instance requestClient.
	
	1 to: aQuantity do:[ :i |
		firstNames add: Character alphabet shuffled anyOne asString ].

	1 to: aQuantity do:[ :i |
		lastNames add: Character alphabet shuffled anyOne asString ].

	1 to: aQuantity do:[ :i | 
		guy := DummyPerson new
				firstName: (firstNames at: i);
				lastName: (lastNames at: i);
				yourself.
		user := DummyUser new
					username: guy firstName;
					person: guy;
					yourself.
		users add: user].

	redisRepository do:[
		delay := Time millisecondsToRun: [
				users do:[ :usr | 
					usr person save.
					usr save]]].
	
	savesPerSecond := ((1000 * aQuantity) / delay asFloat) truncated.
	
	aStream cr;
		nextPutAll: 'Saved ';
		nextPutAll: aQuantity asString;
		nextPutAll: ' instances of MaplessDummyPerson and MaplessDummyUser in: ';
		nextPutAll: delay milliseconds asString;
		nextPutAll: ' ms ';
		nextPutAll: '(~',savesPerSecond asString,' saves per second)';
		flush.
		
	redisRepository do:[ 
		delay := Time millisecondsToRun: [
				users do:[ :usr | 
					user := DummyUser findId: usr oid]]].
	
	readsPerSecond := ((1000 * aQuantity) / delay asFloat) truncated.
			
	aStream cr;
		nextPutAll: 'Read ';
		nextPutAll: aQuantity asString;
		nextPutAll: ' instances of MaplessDummyPerson and MaplessDummyUser in: ';
		nextPutAll: delay milliseconds asString;
		nextPutAll: ' ms ';
		nextPutAll: '(~',readsPerSecond asString,' reads per second)';
		flush
		

