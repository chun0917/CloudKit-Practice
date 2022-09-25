//
//  NameTableViewCell.swift
//  CloudKit-Practice
//
//  Created by 呂淳昇 on 2022/9/23.
//

import UIKit

class NameTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    var delegate: NameTableViewCellListener?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setMoreButton()
        setMenu()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setMoreButton(){
        moreButton.setTitle("", for: .normal)
        moreButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        moreButton.showsMenuAsPrimaryAction = true
    }
    
    func setMenu(){
        let editAction = UIAction(title: "編輯", image: UIImage(systemName: "square.and.pencil"), handler: { action in
            print("編輯")
            self.delegate?.buttonClicked(buttonType: "edit", index: self.index)
        })
        
        let deleteAction = UIAction(title: "刪除", image: UIImage(systemName: "trash.fill"), attributes: .destructive, handler: { action in
            print("刪除")
            self.delegate?.buttonClicked(buttonType: "delete", index: self.index)
        })
        
        let menu = UIMenu(children: [editAction, deleteAction])
        moreButton.menu = menu
    }
}
protocol NameTableViewCellListener{
    func buttonClicked(buttonType: String, index: Int)
}
