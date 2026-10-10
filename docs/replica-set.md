# MongoDB replica set

Sequence diagrams for a Mapless MongoDB replica set. The repository's accessor is a `MaplessMongoReplicaSetPool`. The pool asks a `MaplessMongoReplicaSetResolver` which member is primary. In these examples MongoDB2 is the primary.

`MaplessRepository>>startUp:` sends `start:` to the accessor. `MaplessMongoReplicaSetPool` implements `start`, so startup below is `start`.

## Replica set starts

Pool construction has already registered `#primaryFound` to `onPrimaryFound:` and `#notPrimaryReadWriteAttempt` to `onNotPrimaryReadWriteAttempt:using:`. The resolver's `#rolesUpdated` is registered to `onResolverUpdated`.

```mermaid
sequenceDiagram
    participant app as Application
    participant pool as MaplessMongoReplicaSetPool
    participant resolver as MaplessMongoReplicaSetResolver
    participant client as MongoAPI
    participant MongoDB1
    participant MongoDB2
    participant MongoDB3

    app->>pool: start
    pool->>pool: replicaSetCongifurationHealthcheck
    loop configured mongoUrls until one client opens
        pool->>pool: makeClientWith: aMongoUrl
        alt NetworkError
            pool-->>pool: nil, try the next url
        else socket opens
            pool->>client: open
            client->>MongoDB1: open socket
        end
    end
    alt no configured member accepted a connection
        pool->>pool: signal MaplessNoReplicaSetMemberCouldBeReached
    else a member answered
        pool->>client: replicaSetStatus
        client->>MongoDB1: replSetGetStatus
        MongoDB1-->>client: members
        alt member urls differ from the configured urls
            pool->>pool: signal MaplessReplicaSetInconsistentConfiguration
        else the url sets match
            pool->>resolver: findPrimaryFor:
            Note right of resolver: See Primary discovery. Each success runs the primary-found reactions before the loop continues.
            pool->>pool: startHealthChecker
            Note right of pool: Forks a background loop. It waits healthCheckerInterval, then calls replicaSetAvailabilityHealthcheck.
        end
    end
```

The configuration check leaves its status client open.

## When a primary is recorded

`findPrimaryFor:` does this once for every contacted member whose status names a primary. `updateStatusFromStatus:` runs first, then `#primaryFound`.

```mermaid
sequenceDiagram
    participant pool as MaplessMongoReplicaSetPool
    participant resolver as MaplessMongoReplicaSetResolver

    resolver->>resolver: updateStatusFromStatus:
    Note right of resolver: primaryUrl becomes the primary member's address. secondaryUrls becomes the secondary members' addresses.
    resolver->>pool: trigger #rolesUpdated
    pool->>pool: onResolverUpdated
    pool->>pool: ensureClients
    Note right of pool: ensurePrimaryClients closes read-write clients that are not on the primary, then tops up the minimum. ensureSecondaryClients does the same for read-only clients and the secondary urls.

    pool->>pool: trigger #primaryFound with the contacted url
    pool->>pool: onPrimaryFound:
    pool->>pool: removeInvalidClients
    pool->>pool: ensureMinimumQuantityOfReadOnlyClients
    pool->>pool: ensureMinimumQuantityOfReadWriteClients
    pool->>pool: replicaSetAvailabilityHealthcheck
```

`replicaSetAvailabilityHealthcheck` calls `ensureTopology`, checks that the primary answers a query, checks each secondary, then calls `ensureClients` again. `removeInvalidClients` closes idle read-only clients connected to the primary and idle read-write clients connected anywhere else.

## Write

```mermaid
sequenceDiagram
    participant app as Application
    participant repo as MaplessMongoRepository
    participant pool as MaplessMongoReplicaSetPool
    participant resolver as MaplessMongoReplicaSetResolver
    participant client as MongoAPI
    participant MongoDB2

    app->>repo: readWriteDo:
    repo->>pool: readWriteDo:
    pool->>pool: requestReadWriteClient
    alt primaryUrl is nil
        pool->>resolver: findPrimaryFor:
        Note right of resolver: See Primary discovery. A failure signals ReplicaSetPrimaryNotFound.
    end
    alt an idle read-write client exists
        pool->>pool: getIdleReadWriteClient
    else busy plus idle equals maxReadWriteClients
        pool->>app: signal MaplessMaximumReadWritePoolClientsReached
    else below the maximum
        pool->>pool: makeReadWriteClient
        pool->>client: open to primaryUrl
        client->>MongoDB2: open socket
    end
    alt the client is open and it is invalid or not primary
        pool->>pool: removeReadWriteClient:
        pool->>pool: makeReadWriteClient
    end
    alt the client is nil
        pool->>resolver: resetRoles
        pool->>pool: removeInvalidReadWriteClients
        pool->>app: signal MaplessReadWriteOperationFailed
    else the client is ready
        pool->>pool: move the client from idle to busy
        pool->>repo: run the block with MongoCurrentClient set
        repo->>repo: set MaplessCurrentRepository
        repo->>client: database command
        client->>MongoDB2: command on socket
        MongoDB2-->>client: result
        pool->>pool: returnReadWriteClient: if the client is still valid
        repo-->>app: block result
    end
```

`makeClientWith:` returns nil on `NetworkError`, so a failed open becomes the nil branch above. A client that is already nil is not replaced a second time. Only a live client that fails `isValid` or `isPrimary` is discarded and opened once more.

If the block raises, the pool does not retry the command.

```mermaid
sequenceDiagram
    participant pool as MaplessMongoReplicaSetPool
    participant resolver as MaplessMongoReplicaSetResolver
    participant client as MongoAPI

    alt NetworkError
        pool->>client: reset
        pool->>resolver: resetRoles
        pool->>pool: removeInvalidReadWriteClients
        pool->>pool: signal MaplessReadWriteOperationFailed
    else MongoNotMaster
        pool->>client: reset
        pool->>pool: onNotPrimaryReadWriteAttempt:using:
        Note right of pool: removeInvalidClients, then ensure the minimum read-only and read-write clients.
        pool->>resolver: resetRoles
        pool->>pool: removeInvalidReadWriteClients
        pool->>pool: signal MaplessReadWriteOperationFailed
    else another Error
        pool->>pool: trigger #readWriteError:
        pool->>client: reset
        pool->>pool: pass the error
    end
```

## Primary discovery

```mermaid
sequenceDiagram
    participant pool as MaplessMongoReplicaSetPool
    participant resolver as MaplessMongoReplicaSetResolver
    participant client as MongoAPI
    participant node as Contacted member

    pool->>resolver: findPrimaryFor:
    loop each configured mongoUrl
        resolver->>pool: makeClientWith: mongoUrl
        alt NetworkError
            pool-->>resolver: nil
            Note right of resolver: Skip this url.
        else the client opened
            resolver->>client: replicaSetStatus
            client->>node: replSetGetStatus
            node-->>client: members
            alt no member is primary
                resolver->>client: close
                resolver->>resolver: signal ReplicaSetPrimaryNotFound
                Note right of resolver: Remaining urls are not tried.
            else a member is primary
                resolver->>resolver: updateStatusFromStatus:
                Note right of resolver: primaryUrl is that member's address. Contacting MongoDB1 can still record MongoDB2.
                resolver->>pool: trigger #rolesUpdated
                pool->>pool: trigger #primaryFound with the contacted url
                Note right of pool: onPrimaryFound: runs before the next url.
                resolver->>client: close
            end
        end
    end
    alt primaryUrl is still nil
        resolver->>resolver: signal ReplicaSetPrimaryNotFound
    end
```

Discovery clients are closed. Later reads and writes open their own clients to the recorded primary and secondary urls.
