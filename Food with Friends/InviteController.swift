//
//  SearchController.swift
//  Food with Friends
//
//  Created by Samuel Liu on 4/21/15.
//  Copyright (c) 2015 Samuel Liu. All rights reserved.
//

import UIKit

class InviteController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var id = NSString()
    var attendees = NSArray()
    var friends = NSArray()
    var indices = NSMutableArray()
    var event = Event()

    @IBOutlet weak var btnInvite: UIButton!
    @IBOutlet weak var tableViewFriends: UITableView!
    
    override func viewDidAppear(animated: Bool) {
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        friends = prefs.valueForKey("FRIENDS") as! NSArray
        id = prefs.valueForKey("ID") as! NSString
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableViewFriends.reloadData()
            return
        })
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.tableViewFriends.registerClass(UITableViewCell.self, forCellReuseIdentifier: "friend_cell")
        self.tableViewFriends.dataSource = self
        self.tableViewFriends.delegate = self
        
    }
    
    @IBAction func backTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // get ids of friends invited and upload them to notify table in database
    @IBAction func inviteTapped(sender: AnyObject) {
        var ids = Array<Dictionary<NSString, NSString>>(count:self.indices.count, repeatedValue: [:])
        var ind = 0
        for friend in indices {
            
            // iterate through user-selected indices and prepare to send them to server
            ids[ind]["user_id"] = friends[friend as! NSInteger].valueForKey("id")! as? NSString
            ids[ind]["event_id"] = event.id as NSString
            ids[ind]["inviter_id"] = self.id as NSString
            ind++
        }
        
        let url = NSURL(string: "http://web.engr.illinois.edu/~svliu2/foodwithfriends/sendNotify.php")
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "POST"
        
        var err:NSError?
        let data = NSJSONSerialization.dataWithJSONObject(ids, options: nil, error: &err)!
        
        let idstr = NSString(data: data, encoding: NSUTF8StringEncoding)!
        
        let postString = "ids=\(idstr)" as NSString!
        
        println("post: \(postString)")
        
        request.HTTPBody = postString!.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, request, error in
            
            // error handler
            if error != nil {
                println("Connection error=\(error)")
                return
            }
            var err:NSError?
            if let json: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) {
                // parse JSON response from server
                let parseJSON: AnyObject = json
                var resultValue:String = parseJSON["status"] as! String
                var resultMsg:String = parseJSON["message"] as! String!
                println("result:\(resultValue)")
                println("message:\(resultMsg)")
            }
        }
        
        task.resume()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    // Tableview Delegate Methods
    //
    
    // specify number of rows = number of events
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    // designate the height of each cell
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    // display event name for each cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell = self.tableViewFriends.dequeueReusableCellWithIdentifier("friend_cell") as! UITableViewCell
        
        let friend : NSDictionary = self.friends[indexPath.row] as! NSDictionary
        let name = friend.objectForKey("name") as! String
        let friend_id = friend.objectForKey("id") as! String
        
        // check if friend is already attending
        for user in attendees {
            if friend_id == user as! String {
                cell.accessoryType = .Checkmark
            }
        }
                
        cell.textLabel?.text = name
        
        return cell
    }
    
    // load selected entries into an array
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.indices.addObject(indexPath.row)
    }
    
    // remove deselected entries from array
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.indices.removeObjectIdenticalTo(indexPath.row)
    }
    
    
    

}
