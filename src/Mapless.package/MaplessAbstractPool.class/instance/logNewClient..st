actions
logNewClient: mongoClient
	
	Stdio stderr
		lf;
		<< ('Created mongo client ' , mongoClient printString);
		flush