//
//  ScrollTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/10/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit

class ScrollTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collection:UICollectionView!
    @IBOutlet weak var exerciseLabel:UILabel!
    @IBOutlet weak var setLabel:UILabel!
    @IBOutlet weak var repsLabel:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
extension ScrollTableViewCell{
    
    
    func setCollectionDataSourceDelegate
    <D: UICollectionViewDelegate & UICollectionViewDataSource>
    (_ dataSourceDelegate: D, forRow row: Int)
    {
        collection.delegate = dataSourceDelegate
        collection.dataSource = dataSourceDelegate
        collection.reloadData()
    }
    
}
