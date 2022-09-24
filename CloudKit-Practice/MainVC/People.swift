//
//  People.swift
//  CloudKit-Practice
//
//  Created by 呂淳昇 on 2022/9/23.
//

import Foundation
import CloudKit

struct People {
    var recordID : CKRecord.ID?
    var name : String?
    init(recordID:CKRecord.ID? = nil, name:String){
        self.recordID = recordID
        self.name = name
    }
    //將得到的record轉為上面宣告的struct型態回傳
    static func fromRecord(_ record: CKRecord) -> People?{
        guard let name = record.value(forKey: "name") as? String else{
            return nil
        }
        return People(recordID: record.recordID, name: name)
    }
}
