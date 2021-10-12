"
Mapless uses this class to have pools of Read Only or Read/Write MongoDB clients available for the repository to use.
If more clients are needed, it will create them lazily up to a max.
When the max is reached, it will start throwing exceptions if the load wants to create more.
This particular pool works on N IP addresses that will have 1 master that will do the Write operations and the rest will be Read Only. Is also expected that every command executes optimistically knowing who the master is, and handling exceptions when the cluster changed who's master unexpectedly.
"
Class {
	#name : #MaplessMongoReplicaSetPool,
	#superclass : #Object,
	#category : #'Mapless-Mongo-Core-Connections'
}
