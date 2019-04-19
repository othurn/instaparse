//
//  FeedViewController.swift
//  instaparse
//
//  Created by Oliver Thurn on 4/2/19.
//  Copyright © 2019 Oliver Thurn. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MessageInputBarDelegate {
    @IBOutlet weak var feedTableView: UITableView!
    
    var posts = [PFObject]()            // holds all the post keys from the server
    let messageBar = MessageInputBar()  // message bar instance
    var showsCommentBar = false         // when to show the comment bar at the bottom of the screen
    var selectedPost: PFObject!         // the way to remeber the post that was selected
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedTableView.delegate = self
        feedTableView.dataSource = self
        
        // setting up the comment bar titles
        messageBar.inputTextView.placeholder = "Add a comment ... "
        messageBar.sendButton.title = "Post"
        messageBar.delegate = self
        
        // allows the keyboard to be dismissed when the user pulls down on the tableview
        feedTableView.keyboardDismissMode = .interactive
        
        // setting up the notification center so it can know when the keyboard should be hidden
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardHide(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.commentauthor"])
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.feedTableView.reloadData()
            }
        }
    }
    
    // including the messageinputbar import and these two functions allow for the message bar to be at the bottom of the app
    override var inputAccessoryView: UIView? {
        return messageBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    // hide the keyboard when the
    @ objc func keyboardHide(note: Notification){
        messageBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // add the comment to the server
        let comment = PFObject(className: "comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["commentauthor"] = PFUser.current()

        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground { ( success, error) in
            if success {
                print("Comment saved")
            } else {
                print("Error saving comment")
            }
        }
        
        // reload the table data so new post will show
        feedTableView.reloadData() 
        
        // dismiss the keyboard and the delete the text, need to resign the first responder to get the correct functioality
        messageBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        messageBar.inputTextView.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        return comments.count + 2           // this accounts for the number of comments and the cell for add comment
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0{
            let cell = feedTableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
            let user = post["author"] as! PFUser
            cell.usernameText.text = user.username
            cell.commentText.text = post["caption"] as? String
        
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            cell.photoView.af_setImage(withURL: url)

            return cell
        } else if indexPath.row <= comments.count {
            let cell = feedTableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]
            cell.commentTextLabel.text = comment["text"] as? String
            
            let user = comment["commentauthor"] as! PFUser
            cell.unCommentLabel.text = user.username
            
            return cell
        } else {
            let commentCell = feedTableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return commentCell
        }
    }
    
    // generating random comments when the image is pressed
    // everytime the cell is tapped this function is called 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // allows us to know what cell row was pressed
        let post = posts[indexPath.section]
        
        // creates new category on server for our comments to go into, also creating a place to hold the text and the person
        // who created the comment
        let comment = (post["comments"] as? [PFObject]) ?? []
        
        // If the last cell that holds the add comment feature is selected show the keyboard
        if indexPath.row == comment.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
            messageBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
    }
    
    
    // Creating a way for the user to logout
    // logout user and then recreate the login screen using the storyboard function and the instantiateVC method
    // then use the delegate to show the login window again
    @IBAction func logoutButton(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.rootViewController = loginViewController
    }
}
