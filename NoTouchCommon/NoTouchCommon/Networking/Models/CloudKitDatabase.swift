//
//  CloudKitDatabase.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/3/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CloudKit
import Foundation

private class SubscriptionTracker {
    private static let createdCustomZoneKey = "CreatedCustomZone"
    private static let createdSubscriptionKey = "CreatedZoneSubscription"
    
    private static let subscriptionIDKey = "SubscriptionIDKey"
    
    // MARK: - Zone Creation
    
    static var createdCustomZone: Bool {
        get {
            return UserDefaults.standard.bool(forKey: createdCustomZoneKey)
        } set {
            UserDefaults.standard.set(newValue, forKey: createdCustomZoneKey)
        }
    }
    
    static var attemptingZoneCreation: Bool = false
    
    // MARK: - Zone Subscription
    
    static var hasAddedSubscription: Bool {
        get {
            return UserDefaults.standard.bool(forKey: createdSubscriptionKey)
        } set {
            UserDefaults.standard.set(newValue, forKey: createdSubscriptionKey)
        }
    }
    
    static var attemptingSubscriptionCreation: Bool = false
    
    /// The currently active `CKSubscription.ID`
    static var subscriptionID: String? {
        get {
            return UserDefaults.standard.string(forKey: subscriptionIDKey)
        } set {
            UserDefaults.standard.set(newValue, forKey: subscriptionIDKey)
        }
    }
}

public class CloudKitDatabase: Database {
    
    // Store these to disk so that they persist across launches
    private var subscribedToPrivateChanges = false
     
    private let privateSubscriptionID = "private-changes"
    
    // Use a consistent zone ID across the user's devices
    // CKCurrentUserDefaultName specifies the current user's ID when creating a zone ID
    private let customZoneID = CKRecordZone.ID(zoneName: "TouchZone", ownerName: CKCurrentUserDefaultName)
    private let privateDB: CKDatabase
    private let container = CKContainer.default()
    
    public var initialRecordsFetchState: RecordFetchState = .notAttempted
    
    public weak var delegate: DatabaseDelegate?
    
    public init() {
        self.privateDB = container.privateCloudDatabase
        
        NotificationCenter.default.addObserver(self, selector: #selector(cloudKitAuthStateChanged(_:)), name: Notification.Name.CKAccountChanged, object: nil)

        fetchCloudKitAccountStatus()

        // TODO: Should we call createCustomZone here?
        //createSubscriptions()
    }
    
    private func fetchCloudKitAccountStatus() {
        container.accountStatus { [weak self] accountStatus, error in
            DispatchQueue.main.async { [weak self] in
                if let error = error {
                    print("Error getting account status: \(error.localizedDescription)")
                    self?.delegate?.databaseAuthDidChange(.signedOut)
                    return
                }
                
                switch accountStatus {
                case .available:
                    self?.delegate?.databaseAuthDidChange(.available)
                    self?.attemptCustomZoneCreation()
                    self?.createTouchRecordSubscription()
                    
                case .couldNotDetermine, .noAccount:
                    self?.delegate?.databaseAuthDidChange(.signedOut)
                    
                case .restricted:
                    self?.delegate?.databaseAuthDidChange(.restricted)
                    
                @unknown default:
                    self?.delegate?.databaseAuthDidChange(.signedOut)
                    
                }
            }
        }
    }
    
    @objc private func cloudKitAuthStateChanged(_ notification: Notification) {
        fetchCloudKitAccountStatus()
    }
    
    private func createTouchRecordSubscription() {
        guard !SubscriptionTracker.attemptingSubscriptionCreation, !SubscriptionTracker.hasAddedSubscription else {
            return
        }

        SubscriptionTracker.attemptingSubscriptionCreation = true

        let zoneSub = CKRecordZoneSubscription(zoneID: self.customZoneID)

        let info = CKSubscription.NotificationInfo()
        // Silent notifs
        info.shouldSendContentAvailable = true
        zoneSub.notificationInfo = info

        privateDB.save(zoneSub) { subscription, error in
            SubscriptionTracker.attemptingSubscriptionCreation = false

            if let error = error {
                print("error creating sub: \(error.localizedDescription)")
            } else if let subscription = subscription {
                SubscriptionTracker.hasAddedSubscription = true
                SubscriptionTracker.subscriptionID = subscription.subscriptionID // Save ID for future use.
            }
        }
    }
    
    public func fetchRecords(for date: Date, completionHandler: @escaping (Result<[TouchRecord], DatabaseError>) -> Void) {
        initialRecordsFetchState = .inProcess
        
        /// Turn CKRecord into TouchRecord
        func ckRecordToTouchRecord(_ ckRecord: CKRecord) -> TouchRecord? {
            guard let deviceName = ckRecord["deviceName"] as? String,
                let timestamp = ckRecord["timestamp"] as? Date,
                let version = ckRecord["version"] as? String else {
                    assertionFailure("Why you failin?")
                    return nil
            }
            
            return TouchRecord(deviceName: deviceName,
                               timestamp: timestamp,
                               version: version)
        }
        
        // The array that is to be returned.
        var returnArray: [TouchRecord] = []
        
        // Get the start of the day based on the user's device.
        let startOfDay = Calendar.current.startOfDay(for: date) as NSDate
        
        // Create predicate.
        let predicate = NSPredicate(format: "timestamp >= %@", startOfDay)
        
        let query = CKQuery(recordType: RecordType.touch.rawValue, predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.zoneID = self.customZoneID
        queryOperation.qualityOfService = .userInteractive
        
        /// Runs an initial `operation`, and if we are returned a cursor, recursively creates and runs another operation until all records have been retrieved.
        func fetchAllRecords(with operation: CKQueryOperation, completionHandler: @escaping (Result<Void, DatabaseError>) -> Void) {
            operation.queryCompletionBlock = { newCursor, error in
                if let error = error as? CKError {
                    // If we are told we can retry do so immediately, hoping this will catch errors we're not thinking of/explicitly handling.
                    if let timeToWait = error.userInfo[CKErrorRetryAfterKey] as? NSNumber {
                        operation.cancel() // cancel before trying again
                        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + timeToWait.doubleValue + 3.0) {
                            fetchAllRecords(with: operation, completionHandler: completionHandler)
                        }
                        return
                    }
                    
                    let dbError: DatabaseError
                    
                    switch error.code {
                    case .internalError, .serverRejectedRequest, .serverResponseLost, .limitExceeded:
                        dbError = .databaseError
                        
                    case .managedAccountRestricted, .notAuthenticated, .permissionFailure:
                        dbError = .authenticationFailure
                        
                    case .networkFailure, .networkUnavailable:
                        dbError = .networkFailure
                        
                    case .serviceUnavailable, .requestRateLimited, .zoneBusy: // These should hopefully never get hit because we are retrying ASAP if possible.
                        dbError = .networkFailure
                        
                    default:
                        print("Received default error of type: \(error.localizedDescription)")
                        dbError = .unknownError(error)
                    }
                    
                    completionHandler(.failure(dbError))
                }
                else if let newCursor = newCursor { // We have a cursor, which means more records can be fetched.
                    // Stop the old operation
                    operation.cancel()
                    
                    let newOperation = CKQueryOperation(cursor: newCursor)
                    fetchAllRecords(with: newOperation, completionHandler: completionHandler)
                }
                else { // If we weren't supplied a cursor that means the final operation succeeded, we can now call the final completion, we are done.
                    completionHandler(.success(()))
                }
            }
            
            operation.recordFetchedBlock = { record in
                guard let touchRecord = ckRecordToTouchRecord(record) else {
                    return
                }
                
                returnArray.append(touchRecord)
            }
            
            // add to database to begin operation.
            if !operation.isExecuting {
                privateDB.add(operation)
            }
        }
        
        // Fetch all records
        fetchAllRecords(with: queryOperation) { [weak self] result in
            switch result {
            case .success:
                self?.initialRecordsFetchState = .success
                completionHandler(.success(returnArray)) // Call the main `completionHandler`, passing back all of our succesful values.
                return
                
            case .failure(let error):
                switch error {
                case .authenticationFailure:
                    self?.initialRecordsFetchState = .notAttempted // let us try again once re-authenticated
                    
                default:
                    self?.initialRecordsFetchState = .failure
                    
                }
                
                completionHandler(.failure(error))
                return
                
            }
        }
    }
    
    public func saveTouchRecord(_ record: TouchRecord,
                                completionHandler: @escaping (Result<Void, DatabaseError>) -> Void) {
        let ckRecord = self.ckRecord(from: record, recordZoneID: customZoneID)
        self.privateDB.save(ckRecord) { _, error in
            if let error = error, let ckError = error as? CKError {
                // Attempt a retry if we're told to.
                if let retryTime = ckError.userInfo[CKErrorRetryAfterKey] as? NSNumber {
                    DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + retryTime.doubleValue) { [weak self] in
                        self?.saveTouchRecord(record, completionHandler: completionHandler)
                    }
                    return
                }
                
                switch ckError.code {
                case .serverRejectedRequest, .invalidArguments, .incompatibleVersion, .constraintViolation: // fatal errors
                    completionHandler(.failure(.fatalError))
                    
                default:
                    completionHandler(.failure(.unknownError(error)))
                    
                }
            } else {
                completionHandler(.success(()))
            }
        }
    }
}

// MARK: - Batch Save

extension CloudKitDatabase {
    
    public func saveTouchRecords(_ records: [TouchRecord],
                                 completionHandler: @escaping (Result<Void, DatabaseError>) -> Void) {
        let ckRecords = records.map({ self.ckRecord(from: $0, recordZoneID: self.customZoneID) })
        let operation = CKModifyRecordsOperation(recordsToSave: ckRecords)
        operation.qualityOfService = .userInteractive
        operation.isAtomic = true
        
        operation.modifyRecordsCompletionBlock = { _, _, error in
            if let ckError = error as? CKError {
                // If we have instructions on when to retry simply retry right away.
                if let retryTime = ckError.userInfo[CKErrorRetryAfterKey] as? NSNumber {
                    DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + retryTime.doubleValue) { [weak self] in
                        self?.saveTouchRecords(records, completionHandler: completionHandler)
                    }
                    return
                }
                
                switch ckError.code {
                case .limitExceeded:
                    // split the operation and retry.
                    let halfWayIndex = records.count / 2
                    let arrayOne = Array(records[0..<halfWayIndex])
                    let arrayTwo = Array(records[halfWayIndex..<records.count])
                    
                    self.saveTouchRecords(arrayOne) { result in
                        switch result {
                        case .success: // If we succeed then call the second array with the top level completionHandler
                            self.saveTouchRecords(arrayTwo, completionHandler: completionHandler)
                            
                        case .failure(let error): // We failed on a larger scale that we can't recover from.
                            completionHandler(.failure(error))
                            
                        }
                    }
                    
                case .batchRequestFailed:
                    // TODO: Handle individual failures? How does one do that?
                    completionHandler(.failure(.batchSaveFailed))
                    
                case .managedAccountRestricted, .notAuthenticated, .permissionFailure:
                    completionHandler(.failure(.authenticationFailure)) // tell the user they need to sign in.
                    
                case .serverRejectedRequest, .invalidArguments, .incompatibleVersion, .constraintViolation:
                    completionHandler(.failure(.fatalError))
                    
                default:
                    completionHandler(.failure(.unknownError(ckError)))
                    
                }
            } else {
                completionHandler(.success(()))
            }
        }
        
        // submit
        self.privateDB.add(operation)
    }
}

// MARK: - Creating A Custom Zone

extension CloudKitDatabase {
    
    /// Create a custom zone in order to allow us to subscribe to events
    public func attemptCustomZoneCreation() {
        guard !SubscriptionTracker.createdCustomZone && !SubscriptionTracker.attemptingZoneCreation else {
            return
        }
        
        SubscriptionTracker.attemptingZoneCreation = true
        
        let createZoneGroup = DispatchGroup()
        
        createZoneGroup.enter()
        
        let customZone = CKRecordZone(zoneID: customZoneID)
        
        let createZoneOperation = CKModifyRecordZonesOperation(recordZonesToSave: [customZone], recordZoneIDsToDelete: [])
        
        createZoneOperation.modifyRecordZonesCompletionBlock = { saved, deleted, error in
            SubscriptionTracker.attemptingZoneCreation = false
            
            if error == nil {
                SubscriptionTracker.createdCustomZone = true
            } else {
                print("Failed to create custom zone: \(error!.localizedDescription)")
            }
            
            // else custom error handling
            createZoneGroup.leave()
        }
        createZoneOperation.qualityOfService = .userInitiated
        
        self.privateDB.add(createZoneOperation)
    }
}

// MARK: - Subscribe to Change Notifications

extension CloudKitDatabase {
    
    // NOTE: Does this persist?
    private func createSubscriptions() {
        if !self.subscribedToPrivateChanges {
            let createSubscriptionOperation = createDatabaseSubscriptionOperation(subscriptionID: privateSubscriptionID)
            createSubscriptionOperation.modifySubscriptionsCompletionBlock = { subscriptions, deletedIDs, error in
                if let error = error {
                    // TODO: Fix this.
                    assertionFailure("Failure making subscription: \(error.localizedDescription)")
                } else {
                    self.subscribedToPrivateChanges = true
                }
                self.privateDB.add(createSubscriptionOperation)
            }
        }
    }

    private func createDatabaseSubscriptionOperation(subscriptionID: String) -> CKModifySubscriptionsOperation {
        /// This is the subscription to the changes to the databse. We will pass this to our `CKModifySubscriptionsOperation`.
        let subscription = CKDatabaseSubscription.init(subscriptionID: subscriptionID)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        // send a silent notification
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
        operation.qualityOfService = .utility
        
        return operation
    }
}

// MARK: - Fetching Changes

extension CloudKitDatabase {
    /**
     Flow:
     - Find which database was changed (in our case it will always be private)
     - Fetch the database changes. This allows us to find out what Zones were changed.
     - Then get the changes to each Zone.
     */
    
    public func fetchChanges(in databaseScope: CKDatabase.Scope, completion: @escaping () -> Void) {
        switch databaseScope {
        case .private:
            fetchDatabaseChanges(database: self.privateDB, databaseTokenKey: "private", completion: completion)
            break
            
        case .public, .shared:
            assertionFailure("Fetching changes for a database we shouldn't be using")
            
        default:
            break
            
        }
    }

    private func fetchDatabaseChanges(database: CKDatabase, databaseTokenKey: String, completion: @escaping () -> Void) {
        var changedZoneIDs: [CKRecordZone.ID] = []
        
        let changeToken = "val" as! CKServerChangeToken // TODO: Save the change token to disk (UserDefaults)
        let operation = CKFetchDatabaseChangesOperation(previousServerChangeToken: changeToken)
        
        // Find out what `CKRecordZone` changed.
        operation.recordZoneWithIDChangedBlock = { zoneID in
            changedZoneIDs.append(zoneID)
        }
        
        // Find out what `CKRecordZone` was deleted.
        operation.recordZoneWithIDWasDeletedBlock = { zoneID in
            // TODO: Write this zone deletion to memory
        }
        
        // Get the latest changeToken so we're fetching the latest data.
        operation.changeTokenUpdatedBlock = { token in
            // Flush zone deletions for this database to disk
            // Write this new database change token to memory (This is our 'changeToken' above).
        }
        
        
        /**
         The client is responsible for saving the change token at the end of the operation and passing it into the next call to CKFetchDatabaseChangesOperation. If the server returns a CKErrorChangeTokenExpired error, the previousServerChangeToken value was too old and the client should toss its local cache and re-fetch the changes in this record zone starting with a nil previousServerChangeToken.
         */
        // TODO: Read the doc on this completion block. It contains some important steps that we'll need to adhere to.
        operation.fetchDatabaseChangesCompletionBlock = { token, moreComing, error in
            if let error = error {
                assertionFailure("Error during fetch: \(error.localizedDescription)") // TODO: Handle this error properly. What type of errors can this spit back?
                completion()
                return
            }
            
            // Flush zone deletions for this database to disk
            // Write this new database change token to memory
            
            self.fetchZoneChanges(database: database, databaseTokenKey: databaseTokenKey, zoneIDs: changedZoneIDs) {
                // Flush in-memory database change token to disk
                completion()
            }
        }
        operation.qualityOfService = .userInitiated
        
        database.add(operation)
    }
}

//** Note:  When you are fetching database changes, you need to persist all of the per-zone callbacks you received before getting the database change token. **//

// MARK: - Fetching Zone Changes.

extension CloudKitDatabase
{
    
    /// Fetch the record changes from within the `zoneIDs` array. All items in the `zoneIDs` array were updated.
    private func fetchZoneChanges(database: CKDatabase, databaseTokenKey: String, zoneIDs: [CKRecordZone.ID], completion: @escaping () -> Void) {
        
        // Look up the previous change token for each zone
        var optionsByRecordZoneID: [CKRecordZone.ID: CKFetchRecordZoneChangesOperation.ZoneConfiguration] = [:]
        for zoneID in zoneIDs {
            let options = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
            options.previousServerChangeToken = "old" as! CKServerChangeToken // TODO: How are we going to persist these zone changes?
            optionsByRecordZoneID[zoneID] = options
        }
        
        let operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: zoneIDs, configurationsByRecordZoneID: optionsByRecordZoneID)
        operation.recordChangedBlock = { record in
            print("Record changed: \(record)")
            // Write this record changed to memory TODO: - What about records being added?
        }
        
        operation.recordWithIDWasDeletedBlock = { recordID, recordType in
            print("Record deleted: \(recordID)")
            // Write this deletion to memory (We likely won't need to deal with this for our use case.
        }
        
        operation.recordZoneChangeTokensUpdatedBlock = { zoneID, token, data in
            // Flush record changes and deletions for this zone to disk
            // Write this new zone change token to disk
        }
        
        operation.recordZoneFetchCompletionBlock = { zoneID, changeToken, _, _, error in
            if let error = error {
                print("Error fetching zone changes for \(databaseTokenKey) database: \(error.localizedDescription)")
                return
            }
            
            // Flush record changes and deletions for this zone to disk
            // Write this new zone change token to disk
        }
        
        operation.fetchRecordZoneChangesCompletionBlock = { error in
            if let error = error {
                assertionFailure("Error fetching zone changes for \(databaseTokenKey) database: \(error)")
            }
            
            completion()
        }
        
        database.add(operation)
    }
}
