accessing
find: someConditions limit: howManyResults offset: startingFromWhichResult

	^self currentRepository instancesOf: self where: someConditions limit: howManyResults offset: startingFromWhichResult  
		