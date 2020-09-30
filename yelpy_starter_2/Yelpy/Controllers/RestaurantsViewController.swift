//
//  ViewController.swift
//  Yelpy
//
//  Created by Memo on 5/21/20.
//  Copyright © 2020 memo. All rights reserved.
//

import UIKit
import AlamofireImage

class RestaurantsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            if (!searchText.isEmpty) {
                    var restaurants: [Restaurant] = []
                    // Use each restaurant dictionary to initialize Restaurant object
                    for dictionary in restaurantsArray {
                        let name=dictionary.getName()
                        if(name.lowercased().contains(searchText.lowercased())){
                            restaurants.append(dictionary) // add to restaurants array
                        }
                    }
                restaurantsArrayShown = restaurants
            }
            else {
                restaurantsArrayShown=restaurantsArray
            }
            }
        print(restaurantsArray)
            tableView.reloadData()
        }
    

    @IBOutlet weak var tableView: UITableView!
    
    // ––––– TODO: Build Restaurant Class
    
    // –––––– TODO: Update restaurants Array to an array of Restaurants
    var restaurantsArray: [Restaurant] = []
    var restaurantsArrayShown: [Restaurant] = []
    var searchController: UISearchController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        getAPIData()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        // Sets this view controller as presenting view controller for the search interface
        definesPresentationContext = true
    }
    
    
    // ––––– TODO: Update API to get an array of restaurant objects
    func getAPIData() {
        API.getRestaurants() { (restaurants) in
            guard let restaurants = restaurants else {
                return
            }
            self.restaurantsArray = restaurants
            self.restaurantsArrayShown = restaurants
            self.tableView.reloadData()
        }
    }
    
    // Protocol Stubs
    // How many cells there will be
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantsArrayShown.count
    }
    

    // ––––– TODO: Configure cell using MVC
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create Restaurant Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell") as! RestaurantCell
        
        let restaurant = restaurantsArrayShown[indexPath.row]
        
        cell.r=restaurant
//        // Set name and phone of cell label
//        cell.nameLabel.text = restaurant["name"] as? String
//        cell.phoneLabel.text = restaurant["display_phone"] as? String
//
//        // Get reviews
//        let reviews = restaurant["review_count"] as? Int
//        cell.reviewsLabel.text = String(reviews!)
//
//        // Get categories
//        let categories = restaurant["categories"] as! [[String: Any]]
//        cell.categoryLabel.text = categories[0]["title"] as? String
//
//        // Set stars images
//        let reviewDouble = restaurant["rating"] as! Double
//        cell.starsImage.image = Stars.dict[reviewDouble]!
//
//        // Set Image of restaurant
//        if let imageUrlString = restaurant["image_url"] as? String {
//            let imageUrl = URL(string: imageUrlString)
//            cell.restaurantImage.af.setImage(withURL: imageUrl!)
//        }
        
        return cell
    }
    
    // –––––– TODO: Override segue to pass the restaurant object to the DetailsViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for:cell){
            let r = restaurantsArrayShown[indexPath.row]
            let detailViewController = segue.destination as! RestaurantDetailViewController
            detailViewController.r=r
        }
    }
    

}


