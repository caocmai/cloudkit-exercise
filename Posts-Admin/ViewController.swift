//
//  ViewController.swift
//  Posts-Admin
//
//  Created by Cao Mai on 7/1/20.
//  Copyright © 2020 Cao. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("tableprint", categoryRecords.count)
        return categoryRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let record = categoryRecords[indexPath.row]
        cell.textLabel?.text = record["title"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let record = categoryRecords[indexPath.row]
        deleteRecord(item: record["title"] as! String)
        self.categoryRecords.remove(at: indexPath.row)
        self.table.deleteRows(at: [indexPath], with: .fade)

        
//        self.table.reloadData()

    }
    
    
    var categoryRecords: [CKRecord] = []
        
    var table = UITableView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        createAddButton()
        //        fetchUsersFriends()
//        fetchUserRecord()
//        fetchCategories()
        fetchCategories()
        setUpTable()
//        deleteRecord(item: "summer")

        //        fetchUserName()
        
        
        //// To be notified of changes to the iCloud account's status, all you have to do is register an observer for the .CKAccountChanged notification:
        //        NotificationCenter.default.addObserver(self,
        //                                               selector: #selector(userAccountChanged),
        //                                               name: .CKAccountChanged,
        //                                               object: nil)
        
        
        
        
        
        //        secondContainer.publicCloudDatabase.save(record) { [weak self] savedRecord, error in
        //            guard let _ = savedRecord, error == nil else {
        //                // awesome error handling
        //                print(error!)
        //                return
        //            }
        //            // subscription saved successfully
        //            // (probably want to save the subscriptionID in user defaults or something)
        //            print("saved!")
        //        }
    }
    
    func setUpTable() {
        view.addSubview(table)
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.frame = view.bounds
    }
    
    func createAddButton() {
        let addButton = UIBarButtonItem(title: "Add Category", style: .plain, target: self, action: #selector(addButtonTapped))
        let refresh = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refreshCloud))
        self.navigationItem.rightBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem = refresh
    }
    
    @objc func refreshCloud() {
        fetchCategories()
    }
    
    @objc func addButtonTapped() {
        
        let alertController = UIAlertController(title: "Add Category", message: "Add a new category", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Category"
        }
        alertController.addTextField { (textInput) in
            textInput.placeholder = "Order"
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { action in
            guard let categoryField = alertController.textFields?[0],
                  let orderField = alertController.textFields?[1] else { return }
            
            
            
            let secondContainer = CKContainer.shared
            
            let categoryRecord = CKRecord(recordType: .Category, recordID: .init(recordName: UUID().uuidString))
            
            categoryRecord["title"] = categoryField.text!
            categoryRecord["order"] = Int(orderField.text!)
            
            //               Possible to save like this
            secondContainer.publicCloudDatabase.save(categoryRecord) { (record, error) in
                //                print(record as Any)
                print("saved")
            }
            self.fetchCategories()

        }
        
        alertController.addAction(action)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
        
        
    }
    
    func fetchUserStatus() {
        CKContainer.default().accountStatus { status, error in
            if error != nil {
                // some error occurred (probably a failed connection, try again)
                print("some weird error")
            } else {
                switch status {
                case .available:
                    // the user is logged in
                    print("loggedin")
                case .noAccount:
                    // the user is NOT logged in
                    print("no account")
                case .couldNotDetermine:
                    // for some reason, the status could not be determined (try again)
                    print("dont' know")
                case .restricted:
                    // iCloud settings are restricted by parental controls or a configuration profile
                    print("resitricted")
                @unknown default:
                    // ...
                    print("account error")
                }
            }
        }
        
    }
    
    func fetchUserRecord() {
        CKContainer.default().fetchUserRecordID { recordID, error in // Get user ID
            guard let recordID = recordID, error == nil else {
                // error handling magic
                return
            }
            print("Got user record ID \(recordID.recordName).")
            
            CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { record, error in
                guard let record = record, error == nil else {
                    // show off your error handling skills
                    return
                }
                
                print("The user record is: \(record)")
                print(record["avatar"] as Any)
                
            }
        }
    }
    
    func fetchUsersFriends() { // fetch user's friend that uses the same app
        CKContainer.default().discoverAllIdentities { identities, error in
            guard let identities = identities, error == nil else {
                // awesome error handling
                return
            }
            
            print("User has \(identities.count) contact(s) using the app:")
            print("\(identities)")
        }
    }
    
    
    func fetchUserName() {
        
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            guard let recordID = recordID, error == nil else {
                // error handling magic
                return
            }
            
            
            CKContainer.default().requestApplicationPermission(.userDiscoverability) { status, error in
                guard status == .granted, error == nil else {
                    // error handling voodoo
                    return
                }
                
                CKContainer.default().discoverUserIdentity(withUserRecordID: recordID) { identity, error in
                    guard let components = identity?.nameComponents, error == nil else {
                        // more error handling magic
                        return
                    }
                    
                    DispatchQueue.main.async {
                        let fullName = PersonNameComponentsFormatter().string(from: components)
                        print("The user's full name is \(fullName)")
                    }
                }
            }
        }
        
    }
    
    // Change user avatar image, if there's one
    /// In the snippet above, imageURL is a URL to a local file, if you try to initialize a CKAsset with a remote URL, there will be an exception and your app will crash.
    private func updateUserRecord(_ userRecord: CKRecord, with avatarURL: URL) {
        userRecord["avatar"] = CKAsset(fileURL: avatarURL)
        
        CKContainer.default().publicCloudDatabase.save(userRecord) { _, error in
            guard error == nil else {
                // top-notch error handling
                return
            }
            
            print("Successfully updated user record with new avatar")
        }
    }
    
//    func fetchCategories() {
//        let predicate = NSPredicate(value: true)
//        let query = CKQuery(recordType: "Category", predicate: predicate)
//        let operation = CKQueryOperation(query: query)
//
//
//        operation.recordFetchedBlock = { record in
//            print(record)
//            self.categoryRecords.append(record)
//        }
//
//        operation.queryCompletionBlock = { cursor, error in
//            // recipeRecords now contains all records fetched during the lifetime of the operation
//            print(self.categoryRecords)
//        }
//
//    }
    
    private func fetchCategories() {
        // Fetch Public Database
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        // Initialize Query
        let query = CKQuery(recordType: "Category", predicate: NSPredicate(format: "TRUEPREDICATE"))
        
        // Configure Query
//        query.sortDescriptors = [NSSortDescriptor(key: "latinName", ascending: true)]
        
        // Perform Query
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) -> Void in
            DispatchQueue.main.async {
                self.categoryRecords = records!
                self.table.reloadData()

            }

        }
        
       
    }
    
    func deleteRecord(item: String) {
       let publicDatabase = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(format: "title = %@", item)
        // Initialize Query
        let query = CKQuery(recordType: "Category", predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            let recordToDelete: CKRecord! = records?.first
            if let record = recordToDelete {
                publicDatabase.delete(withRecordID: record.recordID) { (recordID, error) in
                    print(recordID)
                }
            }
        }
    }
    
  
    
    // Get specific stuff for specific user
//    let predicate = NSPredicate(format: "creatorUserRecordID == %@", userRecordID)

    
}

//
//extension CKRecord {
//    subscript(key: Category.RecordKey) -> Any? {
//        get {
//            return self[key.rawValue]
//        }
//        set {
//            self[key.rawValue] = newValue as? CKRecordValue
//        }
//    }
//}
