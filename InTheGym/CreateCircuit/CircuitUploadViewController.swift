//
//  CircuitUploadViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class CircuitUploadViewController: UIViewController {
    
    @IBOutlet weak var tableview:UITableView!
    
    var circuit:circuit!
    
    var integrated : Bool = true
    var save : Bool = true
    var created : Bool = true
    var isPrivate : Bool = false
    
    var options = ["Integrated", "Save", "Add to Created Circuits", "Public"]
    var descriptions = ["Do you want the exercises to integrate with each other?", "Do you want to save this circuit for later use?", "Do you want to add this circuit to your created circuits list?", "Do you want to make this circuit public? It may appear on the DISCOVER page if public."]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UINib(nibName: "CircuitOptionsTableViewCell", bundle: nil), forCellReuseIdentifier: "CircuitOptionsTableViewCell")
        tableview.backgroundColor = Constants.lightColour
        tableview.tableFooterView = UIView()
        tableview.separatorInset = .zero
        tableview.layoutMargins = .zero

    }
    
    func initUI(){
        self.navigationItem.title = "Upload Circuit"
    }
    
    @IBAction func addPressed(_ sender:UIButton){
        if integrated{
            self.circuit.integrated = true
        } else {
            self.circuit.integrated = false
        }
        if save{
            self.saveCircuit()
        }
        print(circuit)
    }
    
    func saveCircuit(){
        // save circuit
    }

}

extension CircuitUploadViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CircuitOptionsTableViewCell", for: indexPath) as! CircuitOptionsTableViewCell
        cell.title.text = options[indexPath.row]
        cell.descriptionText.text = descriptions[indexPath.row]
        cell.delegate = self
        return cell
    }
}

extension CircuitUploadViewController : CircuitOptionsDelegate {
    func valueChanged(on cell: UITableViewCell) {
        let index = self.tableview.indexPath(for: cell)
        switch index?.row{
        case 0:
            integrated.toggle()
        case 1:
            save.toggle()
        case 2:
            created.toggle()
        case 3:
            isPrivate.toggle()
        default:
            break
        }
    }
}
