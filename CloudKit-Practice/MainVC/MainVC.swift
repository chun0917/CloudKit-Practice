//
//  MainVC.swift
//  CloudKit-Practice
//
//  Created by 呂淳昇 on 2022/9/23.
//

import UIKit
import CloudKit

class MainVC: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameTableView: UITableView!
    
    var nameArray = [People]()
    
    private let database = CKContainer(identifier: "iCloud.IOS.CloudKitDemo").publicCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        registerCell()
        fetchItem()
        // Do any additional setup after loading the view.
    }
    
    func setTableView(){
        nameTableView.delegate = self
        nameTableView.dataSource = self
    }
    
    func registerCell(){
        let nib = UINib(nibName: "NameTableViewCell", bundle: nil)
        nameTableView.register(nib, forCellReuseIdentifier: "NameTableViewCell")
    }
    
    func fetchItem(){
        var nameArray = [People]()
        let query = CKQuery(recordType: "People", predicate: NSPredicate(value: true))
        database.fetch(withQuery: query) { result in
            switch result{
            case .success(let result):
                result.matchResults.compactMap { $0.1 }.forEach{
                    switch $0{
                    case .success(let record):
                        if let people = People.fromRecord(record){
                            nameArray.append(people)
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
                self.nameArray = nameArray
                DispatchQueue.main.async {
                    self.nameTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func addItem(_ sender: Any) {
        let record = CKRecord(recordType: "People")
        record.setValue(nameTextField.text!, forKey: "name")
        database.save(record) { [weak self] record, error in
            if record != nil && error == nil{
                print("儲存成功")
                if let newRecord = record{
                    if let newPeople = People.fromRecord(newRecord){
                        DispatchQueue.main.async {
                            self?.nameArray.append(newPeople)
                            self?.nameTableView.reloadData()
                        }
                    }
                }
            }else{
                print(error)
            }
        }
    }
    @IBAction func searchItem(_ sender: Any) {
        
    }
    
}
extension MainVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NameTableViewCell",for: indexPath) as! NameTableViewCell
        cell.nameLabel.text = nameArray[indexPath.row].name
        return cell
    }
    
    
}
