//
//  ViewController.swift
//  preWork
//
//  Created by Chenning Li on 9/1/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var billAmountTextField: UITextField!
    
    @IBOutlet weak var tipPercentageLabel: UILabel!
    
    @IBOutlet weak var tipAmountSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var personNumLabel: UILabel!
    
    @IBOutlet weak var personNumController: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Tip Calculator"
        
//        personNumController.wraps = true
//        personNumController.autorepeat = true
        personNumController.maximumValue = 10
    }

    
    @IBAction func apersonNumChanged(_ sender: UIStepper) {
        personNumLabel.text=Int(sender.value).description
    }
    
    @IBAction func onTap(_ sender: Any) {
    }
        
    
    @IBAction func calculateTip(_ sender: Any) {
        
        let bill=Double(billAmountTextField.text!) ?? 0
        let person=Double(personNumLabel.text!) ?? 1
//        let person=Double(1)
        print("person:", person)
        
        let tipPercentage = [0.15, 0.18, 0.2]

        let tip=bill*tipPercentage[tipAmountSegmentedControl.selectedSegmentIndex]
        let total=(bill+tip)*person

        tipPercentageLabel.text=String(format: "$%.2f", tip)
        totalLabel.text=String(format: "$%.2f", total)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view will appear")
        // This is a good place to retrieve the default tip percentage from UserDefaults
        // and use it to update the tip amount
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("view did appear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("view will disappear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("view did disappear")
    }
}

