//
//  ContactController.swift
//  Contacts2
//
//  Created by Colin Smith on 4/12/19.
//  Copyright © 2019 Colin Smith. All rights reserved.
//

import Foundation
import CloudKit

class ContactController {
    static let shared = ContactController()
    var contacts: [Contact] = []
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    func createContact(name: String, phone: String?, email: String?, completion: @escaping (Contact?) -> Void){
        let newContact = Contact(name: name, phone: phone, email: email)
        let newRecord = CKRecord(contact: newContact)
        publicDB.save(newRecord) { (record, error) in
            if let error = error {
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                completion(nil)
                return
            }
            guard let record = record else {return}
            let contact = Contact(ckRecord: record)
            guard let unwrappedContact = contact else {return}
            self.contacts.append(unwrappedContact)
            completion(unwrappedContact)
        }
    }
    func fetchContacts(completion: @escaping ([Contact]?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Constants.ContactRecordType, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                completion(nil)
                return
            }
            guard let records = records else {return}
            let returnedContacts: [Contact] = records.compactMap{Contact(ckRecord: $0)}
            self.contacts = returnedContacts
            completion(returnedContacts)
        }
    }
    func update(nameToUpdate: String, phoneToUpdate: String?, emailToUpdate: String?, contact: Contact, completion: @escaping (Bool?)->Void){
        publicDB.fetch(withRecordID: contact.recordID) { (record, error) in
            if let error = error {
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                completion(nil)
                return
            }
            record?.setValue(nameToUpdate, forKeyPath: Constants.nameKey)
            record?.setValue(phoneToUpdate, forKeyPath: Constants.phoneKey)
            record?.setValue(emailToUpdate, forKeyPath: Constants.emailKey)
            
            guard let record = record else {return}
            
            
            let updated = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            
            updated.savePolicy = .changedKeys
            updated.queuePriority = .high
            updated.qualityOfService = .userInitiated
            updated.modifyRecordsCompletionBlock = {(records, recordIDs,error) in
                completion(true)
            }
            self.publicDB.add(updated)
        }
    }
}
