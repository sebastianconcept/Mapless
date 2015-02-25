accessing
find: someConditions limit: toHowManyResults

	^self currentRepository instancesOf: self where: someConditions limit: toHowManyResults 
		