"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestMaplessBase,
	#superclass : #PackageManifest,
	#category : #'Mapless-Base-Manifest'
}

{ #category : #'code-critics' }
ManifestMaplessBase class >> ruleRBSentNotImplementedRuleV1FalsePositive [
	^ #(#(#(#RGPackageDefinition #(#'Mapless-Base-Core')) #'2021-09-18T15:55:40.299821-03:00') #(#(#RGClassDefinition #(#MaplessReference)) #'2022-03-13T14:06:38.150255-03:00') )
]
