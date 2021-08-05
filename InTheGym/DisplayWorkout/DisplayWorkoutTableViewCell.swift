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
    func clipButtonTapped(on tableviewcell: UITableViewCell)
}

class DisplayWorkoutTableViewCell: UITableViewCell, workoutCellConfigurable {
    
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
    @IBOutlet weak var clipButton: UIButton!
    
    var delegate:DisplayWorkoutProtocol! {
        didSet{
            self.rpeButton.isUserInteractionEnabled = delegate.returnInteractionEnbabled()
            self.noteButton.isUserInteractionEnabled = true
        }
    }
    
    var cellDelegate:DisplayWorkoutProtocol!
    
    func setup(with rowModel:WorkoutType){
        let model = rowModel as! exercise
        self.exercise = model
        self.exerciseLabel.text = model.exercise
        //self.setsLabel.text = model.setString! + " SETS"
        self.weightLabel.text = model.weight
        self.typeLabel.text = TransformWorkout.bodyTypeToString(from: model.type!)
        self.collection.reloadData()
        self.collection.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        self.collection.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
    }
    
    
    var exercise : exercise! {
        didSet{
            self.exerciseLabel.text = exercise.exercise
            //self.setsLabel.text = exercise.setString! + " SETS"
            self.weightLabel.text = exercise.weight
            self.typeLabel.text = TransformWorkout.bodyTypeToString(from: exercise.type!)
            if exercise.note != nil{
                self.noteButton.isHidden = false
            }else{
                self.noteButton.isHidden = true
            }
            var setInt: Int = 0
            if let setString = exercise.setString {
                self.setsLabel.text = setString + " SETS"
                setInt = Int(setString) ?? 0
            } else if let set = exercise.sets {
                self.setsLabel.text = set.description + " SETS"
                setInt = set
            }
            
            //let setInt = Int(exercise.setString!)!
            if let rep = exercise.reps {
                if rep == 0 {
                    repsLabel.text = "MAX REPS"
                } else {
                    self.repsLabel.text = "\(rep) REPS"
                }
            } else if exercise.repString != nil{
                var x = 0
                var repString = ""
                while x < setInt {
                    repString += exercise.repString!
                    if x != setInt - 1{
                        repString += ","
                    }
                    x += 1
                }
                self.repsLabel.text = repString
            } else if let repArray = exercise.repStringArray {
                var repString = ""
                for rep in repArray{
                    repString += rep + ","
                }
                self.repsLabel.text = String(repString.dropLast())
            } else if let repArray = exercise.repArray {
                var repString = ""
                for rep in repArray {
                    if rep == 0 {
                        repString += "MAX,"
                    } else {
                        repString += rep.description + ","
                    }
                }
                self.repsLabel.text = String(repString.dropLast())
            }
            if let weightArray = exercise.weightArray{
                var weightString = ""
                for weight in weightArray{
                    weightString += weight + ","
                }
                self.weightLabel.text = String(weightString.dropLast())
            }
            if let score = exercise.rpe {
                self.rpeButton.setTitle(score, for: .normal)
                self.rpeButton.setTitleColor(Constants.rpeColors[Int(score)! - 1], for: .normal)
            }
            if !delegate.returnInteractionEnbabled() {
                self.clipButton.isHidden = true
            } else {
                if #available(iOS 13.0, *) {
                    self.clipButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
                }
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
    
    @IBAction func clipButtonTaped(_ sender: UIButton) {
        self.delegate.clipButtonTapped(on: self)
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
        self.repsLabel.text = nil
    }

}
extension DisplayWorkoutTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource{
        
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var setInt: Int = 0
        if let set = exercise.sets {
            setInt = set
        } else if let setString = exercise.setString {
            setInt = Int(setString) ?? 0
        }
        //let setInt = Int(self.exercise.setString!)!
        if delegate.isLive() == true {
            return setInt + 1
        }else{
            return setInt
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let set = exercise.sets ?? 0
        
        if delegate.isLive() && indexPath.item == set {
            
            // here will go the plus cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DisplayPlusCollection", for: indexPath) as! DisplayPlusCollectionViewCell
            cell.parentCell = self
            cell.delegate = self.delegate
            return cell
        }else{
            
            // here will go normal cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DisplayWorkoutCollectionCell", for: indexPath) as! DisplayWorkoutCollectionViewCell
            var cellModel = CollectionCellModel()
            cellModel.set = indexPath.item + 1
            cellModel.completed = self.exercise.completedSets?[indexPath.item] ?? false
            cellModel.parentTableViewCell = self
            if let rep = exercise.reps {
                cellModel.reps = rep
            } else if let rep = self.exercise.repString {
                cellModel.reps = Int(rep) ?? 0
            } else if let reps = exercise.repArray {
                cellModel.reps = reps[indexPath.item]
            } else if let repArray = self.exercise.repStringArray{
                cellModel.reps = Int(repArray[indexPath.item]) ?? 0
            }
            if let weight = self.exercise.weight{
                cellModel.weight = weight
            } else if let weightArray = self.exercise.weightArray{
                cellModel.weight = weightArray[indexPath.item]
            }
            cellModel.weightArray = self.exercise.weightArray
            cell.model = cellModel
            cell.delegate = self.delegate
            cell.completedButton.isUserInteractionEnabled = delegate.returnInteractionEnbabled()
            return cell
        }
        
    }
    
}
