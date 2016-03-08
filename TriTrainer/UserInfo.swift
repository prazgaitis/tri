//
//  UserInfo.swift
//  
//
//  Created by Razgaitis, Paul on 2/29/16.
//
//


/// COPY AND PASTED ALL FROM RAYWENDERLICH BEGINNING CLOUDKIT TUTORIALimport Foundation
/// http://www.raywenderlich.com/83116/beginning-cloudkit-tutorial

import CloudKit

class UserInfo {
    
    let container : CKContainer
    var userRecordID : CKRecordID!
    var contacts = [AnyObject]()
    
    init (container : CKContainer) {
        self.container = container;
    }
    
    /// Attribution: Ray Wonderlich iOS 8 By Tutorials
    
    func loggedInToICloud(completion : (accountStatus : CKAccountStatus, error : NSError!) -> ()) {
        //replace this stub
        completion(accountStatus: .CouldNotDetermine, error: nil)
    }
    
    func userID(completion: (userRecordID: CKRecordID!, error: NSError!)->()) {
        if userRecordID != nil {
            completion(userRecordID: userRecordID, error: nil)
        } else {
            self.container.fetchUserRecordIDWithCompletionHandler() {
                recordID, error in
                if recordID != nil {
                    self.userRecordID = recordID
                }
                completion(userRecordID: recordID, error: error)
            }
        }
    }
    
    func userInfo(recordID: CKRecordID!,
        completion:(userInfo: CKDiscoveredUserInfo!, error: NSError!)->()) {
            //replace this stub
            completion(userInfo: nil, error: nil)
    }
    
    func requestDiscoverability(completion: (discoverable: Bool) -> ()) {
        //replace this stub
        completion(discoverable: false)
    }
    
    func userInfo(completion: (userInfo: CKDiscoveredUserInfo!, error: NSError!)->()) {
        requestDiscoverability() { discoverable in
            self.userID() { recordID, error in
                if error != nil {
                    completion(userInfo: nil, error: error)
                } else {
                    self.userInfo(recordID, completion: completion)
                }
            }
        }
    }
    
    func findContacts(completion: (userInfos:[AnyObject]!, error: NSError!)->()) {
        completion(userInfos: [CKRecordID](), error: nil)
    }
}

