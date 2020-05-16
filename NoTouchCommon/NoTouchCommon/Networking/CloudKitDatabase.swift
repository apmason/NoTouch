//
//  CloudKitDatabase.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/3/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import CloudKit
import Foundation

public class CloudKitDatabase: Database {
    
    typealias RecordItem = CKRecord
    
    public func saveTouchRecord(_ record: TouchRecord,
                                completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let ckRecord = self.ckRecord(from: record)
        self.privateDB.save(ckRecord) { _, error in
            if let error = error {
                completionHandler(.failure(error))
            } else {
                completionHandler(.success(()))
            }
        }
    }
    
    // Store these to disk so that they persist across launches
    private var createdCustomZone = false
    private var subscribedToPrivateChanges = false
     
    private let privateSubscriptionID = "private-changes"
    
    // Use a consistent zone ID across the user's devices
    // CKCurrentUserDefaultName specifies the current user's ID when creating a zone ID
    private let zoneID = CKRecordZone.ID(zoneName: "MyName", ownerName: CKCurrentUserDefaultName)
    private let privateDB: CKDatabase
        
    public init() {
        let container = CKContainer.default()
        self.privateDB = container.privateCloudDatabase
        
        // TODO: Should we call createCustomZone here?
        //createSubscriptions()
    }
    
    public func fetchRecords(for date: Date, completionHandler: @escaping (Result<[TouchRecord], Error>) -> Void) {
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
        
        /// Runs an initial `operation`, and if we are returned a cursor recursively creates and runs another operation until all records have been retrieved.
        func fetchAllRecords(with operation: CKQueryOperation, completionHandler: @escaping (Result<Void, DatabaseError>) -> Void) {
            operation.queryCompletionBlock = { newCursor, error in
                if let error = error as? CKError {
                    var dbError: DatabaseError? = nil
                    switch error.code {
                    case .internalError, .serverRejectedRequest, .serverResponseLost:
                        dbError = .databaseError
                        
                    case .limitExceeded:
                        // TODO: Split the operation into two, for now just use the default db error
                        dbError = .databaseError
                        
                    case .managedAccountRestricted, .notAuthenticated, .permissionFailure:
                        dbError = .authenticationFailure
                        
                    case .networkFailure, .networkUnavailable:
                        print("An error that is returned when the network is available but cannot be accessed.")
                        // TODO: Monitor network reachability, retry operations when available.
                        // Tell the user we're still loading?
                        // Need a backoff timer class
                        dbError = .networkFailure
                        
                    case .serviceUnavailable, .requestRateLimited, .zoneBusy:
                        // Wait the alloted amount of time, then try the operation again.
                        if let timeToWait = error.userInfo[CKErrorRetryAfterKey] as? NSNumber {
                            DispatchQueue.main.asyncAfter(deadline: .now() + timeToWait.doubleValue) {
                                fetchAllRecords(with: operation, completionHandler: completionHandler)
                            }
                        } else {
                            dbError = .networkFailure
                        }
                        
                    default:
                        print("Received default error of type: \(error.localizedDescription)")
                    }
                    
                    guard let unwrappedDBError = dbError else {
                        return
                    }
                    
                    completionHandler(.failure(unwrappedDBError))
                }
                else if let newCursor = newCursor { // We have a cursor, which means more records can be fetched.
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
            privateDB.add(queryOperation)
        }
        
        // Fetch all records
        fetchAllRecords(with: queryOperation) { result in
            switch result {
            case .success:
                completionHandler(.success(returnArray)) // Call the main `completionHandler`, passing back all of our succesful values.
                return
                
            case .failure(let error):
                // FIXME: What does proper error handling look like? What if we are told to fetch again soon? How to fix?
                completionHandler(.failure(error))
                return
                
            }
        }
    }
}

// MARK: - Creating A Custom Zone

extension CloudKitDatabase {
    
    /// Create a custom zone in order to allow us to subscribe to events
    private func createCustomZone() {
        let createZoneGroup = DispatchGroup()
         
        if !self.createdCustomZone {
            createZoneGroup.enter()
            
            let customZone = CKRecordZone(zoneID: zoneID)
            
            let createZoneOperation = CKModifyRecordZonesOperation(recordZonesToSave: [customZone], recordZoneIDsToDelete: [])
            
            createZoneOperation.modifyRecordZonesCompletionBlock = { saved, deleted, error in
                if error == nil {
                    self.createdCustomZone = true
                } else {
                    // TODO: Fix this.
                    assertionFailure("Failed to create custom zone: \(error!.localizedDescription)")
                }
                
                // else custom error handling
                createZoneGroup.leave()
            }
            createZoneOperation.qualityOfService = .userInitiated
            
            self.privateDB.add(createZoneOperation)
        }
    }
}

// MARK: - Subscribe to Change Notifications

extension CloudKitDatabase {
    
    private func createSubscriptions() {
        if !self.subscribedToPrivateChanges {
            let createSubscriptionOperation = createDatabaseSubscriptionOperation(subscriptionID: privateSubscriptionID)
            createSubscriptionOperation.modifySubscriptionsCompletionBlock = { subscriptions, deletedIDs, error in
                if let error = error {
                    // TODO: Fix this.
                    assertionFailure("Failure making subscription: \(error.localizedDescription)")
                } else {
                    print("No error out here")
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

/**
After app launch or the receipt of a push, your app uses CKFetchDatabaseChangesOperation and then CKFetchRecordZoneChangesOperation to ask the server for only the changes since the last time it updated.

The key to these operations is the previousServerChangeToken object, which tells the server when your app last spoke to the server, allowing the server to return only the items that were changed since that time.

First your app will use a CKFetchDatabaseChangesOperation to find out which zones have changed and:

Collect the IDs for the new and updated zones.
Clean up local data from zones that were deleted.
Here is some example code to fetch the database changes:
*/

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
    
//    func fetchChanges(in databaseScope: CKDatabase.Scope, completion: @escaping () -> Void) {
//        switch databaseScope {
//        case .private:
//            fetchDatabaseChanges(database: self.privateDB, databaseTokenKey: "private", completion: completion)
//
//        case .public, .shared:
//            fatalError()
//
//        }
//    }

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

// TODO:
/*
 Advanced Local Caching

 A user can delete your app's data on the CloudKit servers through iCloud Settings->Manage Storage. Your app needs to handle this gracefully and re-create the zone and subscriptions on the server again if they don't exist. The specific error returned in this case is userDeletedZone.

 The operation dependency system outlined in the Advanced NSOperations talk from WWDC2015 is a great way to manage your CloudKit operations so that account and network statuses are checked and zones and subscriptions are created at the right time.

 The network connection may disappear at any time, so make sure to properly handle networkUnavailable errors from any operation.

 Watch for network reachability, and retry the operation when the network becomes available again.
 */


// We'll need something that can configure subscriptions for CloudKit
/**
 After you configure your app to maintain a local cache, here is the general flow your app will follow:

 When your app launches for the first time on a new device it will subscribe to changes in the user's private and shared databases.
 When a user modifies their data locally on Device A your app will send those changes to CloudKit.
 Your app will receive a push notification on the same user's Device B notifying it that there was a change made on the server.
 Your app on Device B will ask the server for the changes that occurred since the last time it spoke with the server and then update its local cache with those changes.
 */
