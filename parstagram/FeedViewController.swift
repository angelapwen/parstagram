//
//  FeedViewController.swift
//  parstagram
//
//  Created by Angela Wen on 11/6/19.
//  Copyright © 2019 Angela Wen. All rights reserved.
//

import UIKit
import Parse
import Alamofire
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Make query from Parse
        let query = PFQuery(className:"Posts")
        
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 20 // Get last 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = post["comments"] as? [PFObject] ?? [] // Nil coalescing operator
        
        return comments.count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = post["comments"] as? [PFObject] ?? [] // Nil coalescing operator
        
        // Post cell is always the 0th row
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            let user = post["author"] as! PFUser
            
            cell.usernameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as! String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            
            let url = URL(string: urlString)!
            DataRequest.addAcceptableImageContentTypes(["application/octet-stream"])
            cell.photoView.af_setImage(withURL: url)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1] // 0th is post
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        }
    }
    
    // Every time user taps on row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Add a comment
        let post = posts[indexPath.row]
        
        let comment = PFObject(className: "Comments")
        comment["text"] = "This is a comment generated when user clicks"
        comment["post"] = post
        comment["author"] = PFUser.current()
        
        post.add(comment, forKey: "comments")
        
        post.saveInBackground { (success, error) in
            if success {
                print("Comment saved")
            } else {
                print("Error saving comment")
            }
        }
    }

    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        
        // Switch user back to login screen
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        delegate.window?.rootViewController = loginViewController
        
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
