"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestMaplessBaseCore,
	#superclass : #PackageManifest,
	#category : #'Mapless-Base-Core-Manifest'
}

{ #category : #'code-critics' }
ManifestMaplessBaseCore class >> ruleRBSentNotImplementedRuleV1FalsePositive [
	^ #(#(#(#RGPackageDefinition #(#'Mapless-Base-Core')) #'2021-09-18T15:55:40.299821-03:00') )
]
