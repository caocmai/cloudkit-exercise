//
//  PostsVC.swift
//  Posts-Admin
//
//  Created by Cao Mai on 7/1/20.
//  Copyright © 2020 Cao. All rights reserved.
//

import UIKit
import CloudKit

class PostsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(postRecords.count)
        return postRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let record = postRecords[indexPath.row]
        cell.textLabel?.text = record["title"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let record = postRecords[indexPath.row]
        self.deleteRecord(item: record["title"] as! String)
        self.postRecords.remove(at: indexPath.row)
        self.table.deleteRows(at: [indexPath], with: .fade)
        
        
        //        self.table.reloadData()
        
    }
    
    
    let datePicker = UIDatePicker()
    let table = UITableView()
    var postRecords: [CKRecord] = []
    
    var selectedCategory: CKRecord!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAddButton()
        fetchPostsOfCategory()
        //        fetchAllPosts()
        setUpTable()
        self.title = selectedCategory["title"]

    }
    
    func setUpTable() {
        view.addSubview(table)
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.frame = view.bounds
    }
    
    func createAddButton() {
        let addButton = UIBarButtonItem(title: "Add Post", style: .plain, target: self, action: #selector(addButtonTapped))
        let refresh = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refreshCloud))
        self.navigationItem.rightBarButtonItems = [addButton, refresh]
        //        self.navigationItem.leftBarButtonItem = refresh
    }
    
    @objc func refreshCloud() {
        fetchPostsOfCategory()
        //        fetchAllPosts()
    }
    
    
    //    func fetchCategoryRecord(item: String) {
    //        let publicDatabase = CKContainer.shared.publicCloudDatabase
    //        let predicate = NSPredicate(format: "title = %@", item)
    //        // Initialize Query
    //        let query = CKQuery(recordType: "Category", predicate: predicate)
    //
    //        publicDatabase.perform(query, inZoneWith: nil) { (records, error) -> Void in
    //
    //            self.categoryRecord = records?.first
    //            //            let recordToDelete: CKRecord! = records?.first
    //            //            guard let record = recordToDelete else { return  }
    //            //            self.gotRecord = record.recordID
    //        }
    //
    //
    //    }
    
    
    @objc func addButtonTapped() {
        //        let pickerToolbar: UIToolbar = UIToolbar(frame: CGRect(x:38, y: 100, width: 244, height: 30))
        //        pickerToolbar.autoresizingMask = .flexibleHeight
        //
        //        let createToolbar = self.createToolbar()
        //        pickerToolbar.items = createToolbar
        //
        //
        let alertController = UIAlertController(title: "Add Post", message: "Add a new post", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Title"
        }
        alertController.addTextField { (textInput) in
            textInput.placeholder = "URL"
        }
        //        alertController.addTextField { (textInput) in
        //            textInput.placeholder = "Category"
        //        }
        //        alertController.addTextField { (textInput) in
        //            textInput.placeholder = "Date"
        //            textInput.inputView = self.datePicker
        //            textInput.inputAccessoryView = pickerToolbar
        //        }
        //
        //
        let action = UIAlertAction(title: "Add", style: .default) { action in
            guard let titleField = alertController.textFields?[0],
                let urlField = alertController.textFields?[1] else { return }
            let secondContainer = CKContainer.shared
            
            let postRecord = CKRecord(recordType: .Post)
            
            postRecord["title"] = titleField.text!
            postRecord["url"] = urlField.text!
            
            let reference = CKRecord.Reference(recordID: self.selectedCategory!.recordID, action: CKRecord_Reference_Action.deleteSelf)
            postRecord["category"] = reference as CKRecordValue
            
            //             let formatter = DateFormatter()
            //                    formatter.dateStyle = .short
            //        dateTextField.text = formatter.string(from: datePicker.date)
            //            alertController.textFields?[2].text = formatter.string(from: self.datePicker.date)
            postRecord["date"] = Date()
            //               Possible to save like this
            secondContainer.publicCloudDatabase.save(postRecord) { (record, error) in
                //                print(record as Any)
                print("saved")
                
            }
            
        }
        
        alertController.addAction(action)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
        
    }
    
    func createToolbar() -> [UIBarButtonItem] {
        // This or the bottom works the same
        //        pickerToolbar.sizeToFit()
        //add buttons
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action:
            #selector(cancelBtnTapped))
        //        cancelButton.tintColor = UIColor.white
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:
            #selector(doneBtnTapped))
        //        doneButton.tintColor = UIColor.white
        
        //add the items to the toolbar
        return [cancelButton, flexSpace, doneButton]
        //        self.dateTextField.inputAccessoryView = pickerToolbar
        
    }
    
    @objc func cancelBtnTapped(_ button: UIBarButtonItem?) {
        datePicker.resignFirstResponder()
        
    }
    
    @objc func doneBtnTapped(_ button: UIBarButtonItem?) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        //        dateTextField.text = formatter.string(from: datePicker.date)
    }
    
    func fetchPostsOfCategory() {
        // Fetch Public Database
        let publicDatabase = CKContainer.shared.publicCloudDatabase
        let reference = CKRecord.Reference(recordID: selectedCategory.recordID, action: .none)
        let predicate = NSPredicate(format: "category == %@", reference)
        
        // Initialize Query
        let query = CKQuery(recordType: "Post", predicate: predicate)
        
        // Configure Query
        //        query.sortDescriptors = [NSSortDescriptor(key: "latinName", ascending: true)]
        
        // Perform Query
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) -> Void in
            DispatchQueue.main.async {
                self.postRecords = records!
                self.table.reloadData()
                
            }
            
        }
        
    }
    
    private func fetchAllPosts() {
        // Fetch Public Database
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        // Initialize Query
        let query = CKQuery(recordType: "Post", predicate: NSPredicate(format: "TRUEPREDICATE"))
        
        // Configure Query
        //        query.sortDescriptors = [NSSortDescriptor(key: "latinName", ascending: true)]
        
        // Perform Query
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) -> Void in
            DispatchQueue.main.async {
                self.postRecords = records!
                self.table.reloadData()
                
            }
            
        }
        
        
    }
    
    
    
    func deleteRecord(item: String) {
        let publicDatabase = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(format: "title = %@", item)
        // Initialize Query
        let query = CKQuery(recordType: "Post", predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            let recordToDelete: CKRecord! = records?.first
            if let record = recordToDelete {
                publicDatabase.delete(withRecordID: record.recordID) { (recordID, error) in
                    print(recordID)
                }
            }
        }
    }
    
    
}

