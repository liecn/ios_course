//
//  TweetViewController.swift
//  Twitter
//
//  Created by Chenning Li on 10/18/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var tweetTextField: UITextView!
    
    @IBOutlet weak var tweetCount: UILabel!
    let characterLimit = 140
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tweetTextField.delegate = self
        tweetTextField.becomeFirstResponder()
        tweetCount.text = "\(characterLimit - tweetTextField.text.count)"+"/"+"\(characterLimit)"
        // Do any additional setup after loading the view.
    }
    func textViewDidChange(_ textView: UITextView) {
        tweetCount.text = "\(characterLimit - tweetTextField.text.count)"+"/"+"\(characterLimit)"
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
       // Set the max character limit

       // Construct what the new text would be if we allowed the user's latest edit
       let newText = NSString(string: textView.text!).replacingCharacters(in: range, with: text)

       // TODO: Update Character Count Label

       // The new text should be allowed? True/False
       return newText.count < characterLimit
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tweet(_ sender: Any) {
        if(!tweetTextField.text.isEmpty){
            TwitterAPICaller.client!.postTweet(tweetString: tweetTextField.text, success: {
            }, failure:{(error) in print("Error posting tweet \(error)")
            })
        }
        self.dismiss(animated: true, completion: nil)
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
