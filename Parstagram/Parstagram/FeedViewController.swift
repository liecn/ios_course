//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Chenning Li on 10/25/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    var posts = [PFObject]()
    let messageInputBar = MessageInputBar()
    var showsCommentBar = false
    var selectedPost: PFObject!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post=posts[section]
        let comments=post["comments"] as? [PFObject] ?? []
        
        return 2+comments.count
    }
    override var inputAccessoryView: UIView?{
        return messageInputBar
    }
    
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            let query = PFQuery(className: "Posts")
            query.includeKeys(["author","comments", "comments.author"])
            query.limit = 20
            
            query.findObjectsInBackground{(posts, error) in
                if posts != nil{
                    self.posts = posts!
                    self.tableView.reloadData()
                }
            }
    //        self.messageInputBar.inputTextView.becomeFirstResponder()
            
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments=post["comments"] as? [PFObject] ?? []
        
        if indexPath.row == 0 {
            let cell=tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostTableViewCell
            
            
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as? String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)
            
            cell.photoView.af.setImage(withURL: url!)
            
            return cell
        } else if indexPath.row <= comments.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row-1]
           
//            comment.fetchInBackground { (object, error) in
//                if error == nil {
//                    // Success!
//                    print("succeed in fetching data")
//                    print(object!)
//                } else {
//                    print("error in fetching data")
//                }
//            }
            
            cell.commentLabel.text = comment["text"] as? String
            
            let author = comment["author"] as! PFUser
            cell.nameLabel.text = author.username
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
    }
    
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // create the comments
        let comment = PFObject(className: "Comments")
    
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        
        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground { (success, error) in
            if success{
                print("Comments saved")
            }else{
                print("Comments failed")
            }
        }
        tableView.reloadData()
        
        messageInputBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        messageInputBar.inputTextView.resignFirstResponder()
        
    }
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageInputBar.inputTextView.placeholder = "Add a comment..."
        messageInputBar.sendButton.title = "Post"
        messageInputBar.delegate = self
        
        tableView.delegate=self
        tableView.dataSource=self
        
        tableView.keyboardDismissMode = .interactive
        // Do any additional setup after loading the view.
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillBeHidden(note: Notification){
        messageInputBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    @IBAction func logout(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController=main.instantiateViewController(withIdentifier: "LoginViewController")
        let sceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        sceneDelegate.window?.rootViewController = loginViewController
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
            messageInputBar.inputTextView.becomeFirstResponder()
            selectedPost = post
        }
        
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
