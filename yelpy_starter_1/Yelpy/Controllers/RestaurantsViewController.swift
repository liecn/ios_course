//
//  ViewController.swift
//  Yelpy
//
//  Created by Memo on 5/21/20.
//  Copyright © 2020 memo. All rights reserved.
//

import UIKit
import AlamofireImage

class RestaurantsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    // ––––– TODO: Add storyboard Items (i.e. tableView + Cell + configurations for Cell + cell outlets)
    // ––––– TODO: Next, place TableView outlet here
    
    
    // –––––– TODO: Initialize restaurantsArray
    var restaurantsArray: [[String:Any?]] = []
    
    
    // ––––– TODO: Add tableView datasource + delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        getAPIData()

    }
    
    
    // ––––– TODO: Get data from API helper and retrieve restaurants
    func getAPIData(){
        API.getRestaurants(){
            (restaurants) in
            guard let restaurants=restaurants else {
                return
            }
            print(restaurants)
            self.restaurantsArray=restaurants
            self.tableView.reloadData()
        }
    }



// ––––– TODO: Create tableView Extension and TableView Functionality

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->Int{
    return restaurantsArray.count
}
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->UITableViewCell{
    let cell=tableView.dequeueReusableCell(withIdentifier: "RestaurantCell") as! RestaurantCell
    let restaurants=restaurantsArray[indexPath.row]
    
    cell.label.text=restaurants["name"] as? String ?? "blank"
    
    if let imageUrlString = restaurants["image_url"] as? String{
        let imageUrl=URL(string:imageUrlString)
        cell.restaurantImage.af.setImage(withURL: imageUrl!)
    }
        return cell
}
    
}
