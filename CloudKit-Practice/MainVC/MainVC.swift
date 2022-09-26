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
    
    //撈CloudKit資料
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
    
    //刪除資料
    func deleteItem(_ recordID : CKRecord.ID){
        database.delete(withRecordID: recordID) { deleteID, error in
            if let error = error{
                print(error)
            }else{
                print("刪除成功")
                self.fetchItem()
            }
        }
    }
    
    //修改資料
    func updateItem(index: Int, value: String){
        database.fetch(withRecordID: nameArray[index].recordID!) { record, error in
            if record != nil && error == nil{
                record?.setValue(value, forKey: "name")
                self.database.save(record!) { [weak self] record, error in
                    if record != nil && error == nil{
                        print("修改成功")
                        self?.fetchItem()
                    }else{
                        print(error)
                    }
                }
            }else{
                print(error)
            }
        }
    }
    
    //新增資料
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
        cell.index = indexPath.row
        cell.delegate = self
        return cell
    }
}
extension MainVC : NameTableViewCellListener{
    func buttonClicked(buttonType: String, index: Int) {
        switch buttonType{
        case "edit":
            let alert = UIAlertController(title: "修改", message: "", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Name"
            }
            let okAction = UIAlertAction(title: "確認", style: .default) { action in
                self.updateItem(index: index, value: alert.textFields![0].text!)
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: false, completion: nil)
        case "delete":
            print(index,nameArray[index].recordID!)
            self.deleteItem(nameArray[index].recordID!)
        default:
            break
        }
    }
    
    
}
