//
//  MyProfileCollectionTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class MyProfileCollectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collection:UICollectionView!
    
    var collectionData = [[String:AnyObject]]()
    
    var delegate : MyProfileProtocol!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        collection.delegate = self
        collection.dataSource = self
        collection.register(UINib(nibName: "MyProfileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyProfileCollectionCell")
        collection.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension MyProfileCollectionTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyProfileCollectionCell", for: indexPath) as! MyProfileCollectionViewCell
        cell.displayImage.image = self.collectionData[indexPath.item]["image"] as? UIImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate.collectionItemSelected(at: indexPath)
    }
    
    
}
