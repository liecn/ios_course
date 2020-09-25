//
//  GridViewController.swift
//  fixster
//
//  Created by Chenning Li on 9/24/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import UIKit
import AlamofireImage

class GridViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout{
    
    
    @IBAction func superheroT(_ sender: Any) {
    }
    @IBOutlet weak var superheroIdTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var movies = [[String:Any]]()
    
   
    @IBAction func onTap(_ sender: Any) {
    }
    @IBAction func surperheroShowup(_ sender: Any) {
        let superheroId=String(superheroIdTextField.text ?? "297762")
                // Do any additional setup after loading the view.
        let url = URL(string: "https://api.themoviedb.org/3/movie/"+superheroId+"/similar?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
                let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
                let task = session.dataTask(with: request) { (data, response, error) in
                   // This will run when the network request returns
                   if let error = error {
                      print(error.localizedDescription)
                   } else if let data = data {
                      let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                      self.movies=dataDictionary["results"] as! [[String:Any]]
                      self.collectionView.reloadData()
                      // TODO: Get the array of movies
                      // TODO: Store the movies in a property to use elsewhere
                      // TODO: Reload your table view data

                   }
                }
                task.resume()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate=self
        collectionView.dataSource=self
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
      layout.minimumLineSpacing = 4
      layout.minimumInteritemSpacing = 4
      let width = (view.frame.size.width - layout.minimumInteritemSpacing * 4) / 3
      layout.itemSize = CGSize(width: width, height: width * 3 / 2)
      return layout.itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
       }
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridViewCell", for: indexPath) as! GridViewCell
        let movie = movies[indexPath.row]
        
        let baseUrl="https://image.tmdb.org/t/p/w185"
        let posterPath=movie["poster_path"] as! String
        let posterUrl = URL(string:baseUrl+posterPath)!
        
        cell.posterView.af.setImage(withURL: posterUrl)
        
        return cell
       }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPath(for: cell)!
        let movie = movies[indexPath.row]
        
        let detailsViewController=segue.destination as! MovieDetailsViewController
        detailsViewController.movie=movie
        collectionView.deselectItem(at: indexPath, animated: true)
    }

}
