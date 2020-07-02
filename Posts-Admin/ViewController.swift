//
//  ViewController.swift
//  Posts-Admin
//
//  Created by Cao Mai on 7/1/20.
//  Copyright © 2020 Cao. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let secondContainer = CKContainer.shared
        
        let record = CKRecord(recordType: "Post")
        record["title"] = "macbook"
        record["url"] = "www.mac.com"
                record["date"] = Date()
        
        // Possible to save like this
        //        secondContainer.publicCloudDatabase.save(record) { (record, error) in
        //            print(record)
        
        secondContainer.publicCloudDatabase.save(record) { [weak self] savedRecord, error in
            guard let _ = savedRecord, error == nil else {
                // awesome error handling
                print(error!)
                return
            }
            // subscription saved successfully
            // (probably want to save the subscriptionID in user defaults or something)
            print("saved!")
        }
    }
    
    
}


extension CKRecord {
    subscript(key: Category.RecordKey) -> Any? {
        get {
            return self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue as? CKRecordValue
        }
    }
}
