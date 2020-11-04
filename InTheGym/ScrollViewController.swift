//
//  ScrollViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/10/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit

class ScrollViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource{
    
    // variables passed from previous page
    var weight = ""
    var sets = ""
    var reps = ""
    var repArray = [String]()
    var variedReps:Bool!
    
    //var reps = ["10", "8", "6", "4"]
    //var weight = ["100kg", "110kg", "120kg", "140kg"]
    //var reps = ["10", "8", "6", "4", "4", "4"]
    //var weight = ["100kg", "110kg", "120kg", "140kg", "140kg", "145kg"]
    var numbers = [1,2,3,4,5,6,5,4,3,2,1]
    
    var counter = 0
    
    @IBOutlet weak var tableview:UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.rowHeight = 400
        

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell") as! ScrollTableViewCell
        self.counter = indexPath.row
        cell.collection.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        cell.collection.reloadData()
        let indexPath2 = IndexPath(item: 0, section: 0)
        cell.collection.scrollToItem(at: indexPath2, at: .left, animated: false)
        //cell.setLabel.text = "\(numbers[indexPath.row]) SETS"
        cell.setLabel.text = "\(self.sets) SETS"
        if !variedReps{
            let setInt = Int(self.sets)!
            var x = 0
            var repString = ""
            while x < setInt {
                repString += self.reps
                if x != setInt - 1{
                    repString += ","
                }
                x += 1
            }
            cell.repsLabel.text = repString
        }
        else{
            var repString = ""
            for rep in repArray{
                repString += rep
                repString += ","
            }
            cell.repsLabel.text = String(repString.dropLast())
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        counter += 1
        let setInt = Int(sets)!
        return setInt
        //return numbers[counter - 1]
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! InsideCollectionViewCell
        cell.layer.cornerRadius = 10
        cell.contentView.layer.cornerRadius = 10
        //cell.layer.borderWidth = 2
        cell.contentView.layer.borderWidth = 2
        //cell.layer.borderColor = UIColor.black.cgColor
        cell.contentView.layer.borderColor = UIColor.black.cgColor
        //cell.layer.masksToBounds = true
        cell.contentView.layer.masksToBounds = true
        cell.backgroundColor = #colorLiteral(red: 0, green: 0.4618991017, blue: 1, alpha: 1)
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        cell.layer.shadowRadius = 6.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        //cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath

        if !variedReps{
            cell.repsLabel.text = "\(self.reps) reps"
        }
        else{
            cell.repsLabel.text = "\(self.repArray[indexPath.row]) reps"
        }
        
        cell.weightLabel.text = self.weight
        cell.setLabels.text = "SET \(indexPath.row + 1)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let lastIndexToScroll = collectionView.numberOfItems(inSection: 0) - 1
        if indexPath.row < lastIndexToScroll{
            let indexToScroll = IndexPath.init(row: indexPath.row + 1, section: 0)
            collectionView.scrollToItem(at: indexToScroll, at: .left, animated: true)
        }
        
    }
    


}
