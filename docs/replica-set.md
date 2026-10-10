# MongoDB replica set

Sequence diagrams for a Mapless repository on a MongoDB replica set: startup, a write that has to find the primary, and primary discovery. MongoDB2 is the primary.

## Replica set starts

```mermaid
sequenceDiagram
    participant app as Application
    participant repo as MaplessRepository
    participant pool as MaplessReplicaSetPool
    participant resolver as MaplessReplicaSetResolver
    participant client as MongoDB client
    participant MongoDB1
    participant MongoDB2
    participant MongoDB3

    Note over app,MongoDB3: Starting the repository
    app->>repo: start
    Note right of repo: The application just instantiated the repo and wants it ready to use. The start method can be thought as part of the initialization of the repo.
    repo->>repo: onPrimaryFound
    Note right of repo: Setup a reaction for when a primary node is discovered.
    repo->>repo: onPrimaryUnavailable
    Note right of repo: Setup a reaction for when none of the nodes is a primary.
    repo->>pool: start
    pool->>pool: findPrimary
    pool->>repo: aMaplessPool
    repo->>app: aMaplessRepository

    Note over repo,pool: onPrimaryFound
    repo->>pool: primaryFound
    pool->>pool: removeInvalidClients
    pool->>pool: ensureMinimumQuantityOfReadOnlyClients
    pool->>pool: ensureMinimumQuantityOfReadWriteClients

    Note over repo,pool: onPrimaryUnavailable
    repo->>pool: primaryUnavailable
    pool->>pool: removeInvalidClients
    pool->>pool: ensureMinimumQuantityOfReadOnlyClients
```

## Write while finding the primary

```mermaid
sequenceDiagram
    participant app as Application
    participant repo as MaplessRepository
    participant pool as MaplessReplicaSetPool
    participant resolver as MaplessReplicaSetResolver
    participant client as MongoDB client
    participant MongoDB1
    participant MongoDB2
    participant MongoDB3

    app->>repo: readWriteDo:
    repo->>pool: readWriteDo:
    pool->>pool: requestReadWriteIdleClient
    pool->>resolver: requestClientFor: aMongoUrl
    alt aMongoClient (read-write)
        resolver->>pool: aMongoClient (read-write)
        pool->>client: command:
        client->>MongoDB2: command on socket
        MongoDB2->>client: successful write operation
        client->>pool: successful write operation
        pool->>repo: successful write operation
        repo->>app: successful write operation
    else nil
        resolver->>pool: nil
        pool->>resolver: hasPrimary
        Note right of pool: No client to the primary was returned. Need to create one if the primary address is known or find what's the address of the primary if it's unknown.
        alt the address of the primary node is known
            resolver->>pool: true
            pool->>pool: makeReadWriteClient
            pool->>resolver: getReadWriteMongoUrl
            resolver->>pool: aMongoUrl
            pool->>client: open
            alt the client connection opens
                pool->>pool: addReadWriteClientToBusy
                pool->>pool: aMongoClient
                pool->>client: command:
                client->>MongoDB2: command on socket
                MongoDB2->>client: successful write operation
                client->>pool: successful write operation
                pool->>repo: successful write operation
                repo->>app: successful write operation
            else there is a NetworkError
                pool->>pool: onNetworError
                pool->>pool: findPrimary
                pool->>pool: aMongoClient (read-write)
                pool->>client: command:
                client->>MongoDB2: command on socket
                MongoDB2->>client: successful write operation
                client->>pool: successful write operation
                pool->>repo: successful write operation
                repo->>app: successful write operation
            end
        else the address of the primary node is unknown
            resolver->>pool: false
            pool->>pool: findPrimary
            pool->>pool: aMongoClient (read-write)
            pool->>client: command:
            client->>MongoDB2: command on socket
            MongoDB2->>client: successful write operation
            client->>pool: successful write operation
            pool->>repo: successful write operation
            repo->>app: successful write operation
        end
    end

    pool->>pool: onReadWriteClientNeeded
    pool->>pool: onReadOnlyClientRequested
    pool->>pool: onPrimaryFound
    pool->>pool: onPrimaryUnavailable
    pool->>pool: findPrimary
    loop every (valid) mongoUrl
        pool->>client: command:
        pool->>client: isPrimary
        alt true
            client->>MongoDB2: isPrimary
            MongoDB2->>client: true
            client->>pool: true
            pool->>pool: signals PrimaryFound
        else false
            pool->>pool: signals PrimaryNotFound
        end
    end
```

## Primary discovery

```mermaid
sequenceDiagram
    participant pool as MaplessReplicaSetPool
    participant resolver as MaplessReplicaSetResolver
    participant client as MongoDB client
    participant MongoDB1
    participant MongoDB2
    participant MongoDB3

    Note over pool,MongoDB3: Primary discovery process
    pool->>pool: findPrimary
    loop every mongoUrl in the ReplicaSet config
        pool->>resolver: requestClientFor: aMongoUrl
        resolver->>pool: aMongoClient
        pool->>client: isPrimary
        alt true
            client->>MongoDB2: isPrimary
            MongoDB2->>client: true
            client->>pool: true
            pool->>pool: signals PrimaryFound
        else false
            pool->>pool: signals PrimaryNotFound
        end
    end
```
