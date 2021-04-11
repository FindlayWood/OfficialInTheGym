//
//  DisplayWorkoutTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

protocol WorkoutTableCellTapDelegate:NSObject {
    func noteButtonTapped(on tableviewcell:UITableViewCell)
    func rpeButtonTappped(on tableviewcell:UITableViewCell, sender:UIButton, collection:UICollectionView)
    func completedCell(on tableviewcell:UITableViewCell, on item:Int, sender:UIButton, with cell:UICollectionViewCell)
}

class DisplayWorkoutTableViewCell: UITableViewCell {
    
    @IBOutlet var exerciseLabel:UILabel!
    @IBOutlet var weightLabel:UILabel!
    @IBOutlet var setsLabel:UILabel!
    @IBOutlet var repsLabel:UILabel!
    @IBOutlet var typeLabel:UILabel!
    @IBOutlet var setsTextField:UITextField!
    @IBOutlet var repsTextField:UITextField!
    @IBOutlet var infoButton:UIButton!
    @IBOutlet var rpeButton:UIButton!
    @IBOutlet var noteButton:UIButton!
    @IBOutlet var collection:UICollectionView!
    
    weak var delegate:WorkoutTableCellTapDelegate!
    
    var cellDelegate:DisplayWorkoutProtocol!
    
    
    var exercise : exercise! {
        didSet{
            self.exerciseLabel.text = exercise.exercise
            self.setsLabel.text = exercise.sets! + " SETS"
            self.weightLabel.text = exercise.weight
            self.typeLabel.text = TransformWorkout.bodyTypeToString(from: exercise.type!)
            if exercise.note != nil{
                self.noteButton.isHidden = false
            }else{
                self.noteButton.isHidden = true
            }
            
            let setInt = Int(exercise.sets!)!
            if exercise.reps != nil{
                var x = 0
                var repString = ""
                while x < setInt {
                    repString += exercise.reps!
                    if x != setInt - 1{
                        repString += ","
                    }
                    x += 1
                }
                self.repsLabel.text = repString
            }
        }
    }
    var isLive : Bool!
    
    @IBAction func noteButtonTapped(_ sender:UIButton){
        self.delegate.noteButtonTapped(on: self)
    }
    
    @IBAction func rpeButtonTapped(_ sender:UIButton){
        self.delegate.rpeButtonTappped(on: self, sender: sender, collection: self.collection)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        
        self.collection.delegate = self
        self.collection.dataSource = self
        
        self.collection.register(UINib(nibName: "DisplayCollectionCell", bundle: nil), forCellWithReuseIdentifier: "DisplayWorkoutCollectionCell")
        self.collection.register(UINib(nibName: "DisplayPlusCollection", bundle: nil), forCellWithReuseIdentifier: "DisplayPlusCollection")
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.rpeButton.setTitle("RPE", for: .normal)
        self.rpeButton.setTitleColor( .systemBlue, for: .normal)
    }

}
extension DisplayWorkoutTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource{
        
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let setInt = Int(self.exercise.sets!)!
        if isLive == true {
            return setInt + 1
        }else{
            return setInt
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isLive && indexPath.item == Int(self.exercise.sets!){
            
            // here will go the plus cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DisplayPlusCollection", for: indexPath) as! DisplayPlusCollectionViewCell
            return cell
        }else{
            
            // here will go normal cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DisplayWorkoutCollectionCell", for: indexPath) as! DisplayWorkoutCollectionViewCell
            let cellModel = CollectionCellModel(set: indexPath.item + 1,
                                                weight: self.exercise.weight,
                                                completed: self.exercise.completedSets![indexPath.item],
                                                reps: self.exercise.reps,
                                                parentTableViewCell: self)
            cell.model = cellModel
            cell.delegate = self.cellDelegate
            cell.completedButton.isUserInteractionEnabled = cellDelegate.returnInteractionEnbabled()
            return cell
        }
        
    }
    
}
