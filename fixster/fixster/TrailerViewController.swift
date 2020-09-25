//
//  TrailerViewController.swift
//  fixster
//
//  Created by Chenning Li on 9/24/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import UIKit
import WebKit

class TrailerViewController: UIViewController,WKUIDelegate {
    @IBOutlet weak var trailerView: WKWebView!
    var movie: [String:Any]!
    var video_info: [String:Any]?
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        trailerView = WKWebView(frame: .zero, configuration: webConfiguration)
        trailerView.uiDelegate = self
        view = trailerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(movie!)
        let movie_id=String (describing: movie["id"])
        
        let url = URL(string: "https://api.themoviedb.org/3/movie/" + movie_id + "/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
           // This will run when the network request returns
           if let error = error {
              print(error.localizedDescription)
           } else if let data = data {
              let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]

            self.video_info=dataDictionary["results"] as? [String:Any]
            let video_key=self.video_info?["keys"] as? String ?? "SUXWAEX2jlg"
            
            
            let video_link=URL(string:"https://www.youtube.com/watch?v="+video_key)
            self.trailerView.load(URLRequest(url:video_link!))
              // TODO: Get the array of movies
              // TODO: Store the movies in a property to use elsewhere
              // TODO: Reload your table view data

           }
        }
        task.resume()
        
        // Do any additional setup after loading the view.
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
