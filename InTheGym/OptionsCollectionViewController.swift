//
//  OptionsCollectionViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/05/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView

class OptionsCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate {
    
    // outlet to the collection view
    @IBOutlet weak var collectionview:UICollectionView!
    
    // outlet to the label to distance choosen measurement
    @IBOutlet weak var label:UITextField!
    
    // outlet to switch control for note
    @IBOutlet weak var noteSwitch:UISwitch!
    
    // outlet to text view for adding note
    @IBOutlet weak var note:UITextView!
    
    // array holding labels and their abbreviations
    var labels : [String] = ["Metres", "km", "Miles", "Minutes", "Nothing"]
    var attachments : [String] = ["m", "km", "mi", "mins", ""]
    
    // array holding images which will be changed to more appropraite images soon
    let images : [UIImage] = [#imageLiteral(resourceName: "weight"), #imageLiteral(resourceName: "weight2"), #imageLiteral(resourceName: "weight3"), #imageLiteral(resourceName: "weight4"), #imageLiteral(resourceName: "weight5")]
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! OptionsCollectionViewCell
        cell.image.image = images[indexPath.item]
        cell.label.text = labels[indexPath.item]
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 2
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("you selected " + labels[indexPath.item])
        if indexPath.item == 4{
            let alert = SCLAlertView()
            alert.addButton("Yes") {
                self.label.text?.removeAll()
            }
            alert.showWarning("No measurement", subTitle: "Are you sure you want this exercise to have no measurement?", closeButtonTitle: "cancel")
        }
        else{
            let alert = SCLAlertView()
            let distance = alert.addTextField()
            distance.placeholder = "enter distance in \(labels[indexPath.item])"
            distance.keyboardType = .decimalPad
            alert.addButton("Confirm") {
                if distance.text == ""{
                    self.showError()
                }else{
                    let dist = distance.text!
                    let show = dist + self.attachments[indexPath.item]
                    self.label.text = show
                    
                    
                }
            }
            alert.showSuccess("\(labels[indexPath.item])!", subTitle: "Enter a measurement", closeButtonTitle: "cancel")
        }
        
        
        
    }
    
    func showError(){
          // new alert
          let alert = SCLAlertView()
          alert.showError("Error", subTitle: "Enter a distance", closeButtonTitle: "ok", animationStyle: .noAnimation)
          
      }
    
    @objc func stateChanged(switchState: UISwitch){
        if noteSwitch.isOn {
            note.isHidden = false
        } else {
            note.isHidden = true
        }
    }
    
    @IBAction func addExercise(_ sender:UIButton){
        
        if note.isHidden == true{
            let dictData = ["exercise": "exercise",
                            "sets": "sets",
                            "reps": "reps",
                            "distance": "\(self.label.text!)"
            ]
            
            print(dictData)
        }else{
            let dictData = ["exercise": "exercise",
                            "sets": "sets",
                            "reps": "reps",
                            "distance": "\(self.label.text!)",
                            "note": "\(self.note.text!)"
                ]
            print(dictData)
        }
            
        
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.isUserInteractionEnabled = false
        
        note.textContainer.maximumNumberOfLines = 5
        note.textContainer.lineBreakMode = .byTruncatingTail
        note.isScrollEnabled = false
        note.isHidden = true
        noteSwitch.isOn = false
        if noteSwitch.isOn == false{
            noteSwitch.backgroundColor = .red
            noteSwitch.layer.cornerRadius = noteSwitch.frame.height / 2
        }
        
        noteSwitch.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        
        note.text = "enter a note for the player to view..."
        note.textColor = .lightGray
        note.delegate = self
        hideKeyboardWhenTappedAround()
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
           if note.textColor == UIColor.lightGray {
               note.text = nil
               note.textColor = UIColor.black
           }
       }
       
       func textViewDidEndEditing(_ textView: UITextView) {
           if note.text.isEmpty {
               note.text = "enter a note for the player to view..."
               note.textColor = UIColor.lightGray
           }
       }
    

}

extension OptionsCollectionViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfColumns : CGFloat = 2
        let numberOfRows : CGFloat = 3
        let width = collectionView.frame.size.width
        let height = collectionView.frame.size.height
        let xInsets : CGFloat = 10
        let cellSpacing : CGFloat = 5
        
        if (indexPath.item == 4){
            return CGSize(width: (width) - ((xInsets*1.5) + cellSpacing), height: (height / numberOfRows) - (xInsets + cellSpacing))
        }
        else{
            return CGSize(width: (width / numberOfColumns) - (xInsets + cellSpacing), height: (height / numberOfRows) - (xInsets + cellSpacing))
        }
             
       }
}

