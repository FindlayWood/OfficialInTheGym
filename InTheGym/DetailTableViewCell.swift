//
//  DetailTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit

protocol infoButtonsDelegate{
    func infoButtonTapped(at index:IndexPath)
    func rpeButtonTapped(at index:IndexPath, sender:UIButton, view: UICollectionView)
}

protocol noteButtonDelegate {
    func noteButtonTapped(at index:IndexPath)
}

class DetailTableViewCell: UITableViewCell {
    
    @IBOutlet var exerciseLabel:UILabel!
    @IBOutlet var weightLabel:UILabel!
    @IBOutlet var setsLabel:UILabel!
    @IBOutlet var repsLabel:UILabel!
    @IBOutlet var setsTextField:UITextField!
    @IBOutlet var repsTextField:UITextField!
    @IBOutlet var infoButton:UIButton!
    @IBOutlet var rpeButton:UIButton!
    @IBOutlet var noteButton:UIButton!
    @IBOutlet var collection:UICollectionView!
    
    var delegate:infoButtonsDelegate!
    var ndelegate:noteButtonDelegate!
    var indexPath:IndexPath!
    
    @IBAction func infoTapped(_ sender:UIButton){
        self.delegate.infoButtonTapped(at: indexPath)
    }
    
    @IBAction func noteTapped(_ sender:UIButton){
        self.ndelegate.noteButtonTapped(at: indexPath)
    }
    
    @IBAction func rpeTapped(_ sender:UIButton){
        self.delegate.rpeButtonTapped(at: indexPath, sender: sender, view: collection)
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
extension DetailTableViewCell{
    
    
    func setCollectionDataSourceDelegate
    <D: UICollectionViewDelegate & UICollectionViewDataSource>
    (_ dataSourceDelegate: D, forRow row: Int)
    {
        collection.delegate = dataSourceDelegate
        collection.dataSource = dataSourceDelegate
        collection.reloadData()
    }
    
}
