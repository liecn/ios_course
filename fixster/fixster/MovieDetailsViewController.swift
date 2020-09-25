//
//  MovieDetailsViewController.swift
//  fixster
//
//  Created by Chenning Li on 9/24/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import UIKit
import AlamofireImage

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    
    var movie: [String:Any]!
    
//    @objc func didTap(sender: UITapGestureRecognizer) {
//       print("123123")
//       // User tapped at the point above. Do something with that if you want.
//    }
    
    //    @IBAction func didType(_ sender: UITapGestureRecognizer) {
////        let scale = sender.scale
//        let imageView = sender.view as! UIImageView
//        imageView.transform = imageView.transform.scaledBy(x: 10, y: 10)
//
//    }
    
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        print("123123")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Optionally set the number of required taps, e.g., 2 for a double click
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
//        tapGestureRecognizer.numberOfTapsRequired = 2
//
//        // Attach it to a view of your choice. If it's a UIImageView, remember to enable user interaction
        posterImage.isUserInteractionEnabled = true
//        posterImage.addGestureRecognizer(tapGestureRecognizer)
        
        
        
        let baseUrl="https://image.tmdb.org/t/p/w185"
        let posterPath=movie["poster_path"] as! String
        let posterUrl = URL(string:baseUrl+posterPath)!

        let backPath=(movie["backdrop_path"] as? String)!
        let backUrl = URL(string:"https://image.tmdb.org/t/p/w780"+backPath)!
        
        titleLabel.text = movie["title"] as? String
        titleLabel.sizeToFit()
        synopsisLabel.text = movie["overview"] as? String
        synopsisLabel.sizeToFit()
        
        posterImage.af.setImage(withURL: posterUrl)
        backImage.af.setImage(withURL: backUrl)
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        let trailerViewController=segue.destination as! TrailerViewController
        trailerViewController.movie=movie
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
