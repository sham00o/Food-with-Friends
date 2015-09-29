//
//  EventController.swift
//  Food with Friends
//
//  Created by Samuel Liu on 4/16/15.
//  Copyright (c) 2015 Samuel Liu. All rights reserved.
//

import UIKit

class EventController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let userid:NSString = NSUserDefaults.standardUserDefaults().valueForKey("ID") as! NSString
    let friends = NSUserDefaults.standardUserDefaults().valueForKey("FRIENDS") as! NSArray
    
    @IBOutlet weak var tableViewEvents: UITableView!

    var invites = NSMutableArray()
    var events = NSMutableArray()
    var index = NSInteger()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableViewEvents.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableViewEvents.dataSource = self
        self.tableViewEvents.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
        
        // download events from "events" database and reload table
        downloadEvents()
        
        // if current invites are exhausted then download invites from "notify" database and prompts user
        // otherwise prompt existing invites
        if invites.count == 0 {
            downloadInvites()
        } else {
            promptInvites()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // download json of all queried events in events table from server
    func downloadEvents() {
        
        // reset Events variable
        events = NSMutableArray()
        
        let url = NSURL(string: "http://web.engr.illinois.edu/~svliu2/foodwithfriends/getAllEvents.php");
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        
        // get saved userid
        let username:NSString = NSUserDefaults.standardUserDefaults().valueForKey("NAME") as! NSString
        
        let postString = "userid=\(userid)"
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        // connect to server
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in

            // error handler
            if error != nil {
                println("CONNECTION ERROR:\(error)")
                return
            }
            // parse each element into an Event object
            var jsonArray = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: nil) as? Array<NSDictionary>
            
            if jsonArray != nil {
                
                let size = jsonArray!.count
                
                    for i in 0...size-1 {
                        var jsonElement: NSDictionary = jsonArray![i]
                        var event = Event()
                        event.id = jsonElement["event_id"] as! NSString;
                        event.creator_id = jsonElement["creator_id"] as! NSString;
                        event.name = jsonElement["name"] as! NSString;
                        event.time = jsonElement["time"] as! NSString;
                        event.date = jsonElement["date"] as! NSString;
                        event.location = jsonElement["location"] as! NSString;
                        
                        var add = false
                        
                        // if event is created by me or my friends then add
                        for friend in self.friends {
                            let friendname = friend.objectForKey("name") as! String
                            let id = friend.objectForKey("id") as! String
                            if id == event.creator_id {
                                add = true
                                event.creator_name = friendname
                                break
                            }
                        }
                        if self.userid == event.creator_id {
                            add = true
                            event.creator_name = username
                        }
                        if add == true {
                            self.events.addObject(event)
                        }
                    }
            }
            // call delegate method to asynchronously reload content
            dispatch_async(dispatch_get_main_queue(), {
                self.tableViewEvents.reloadData()
                return
            })
        }
        task.resume()
    }
    
    // download invites from database corresponding to user's id
    func downloadInvites() {
        
        // reset Invites array
        invites = NSMutableArray()

        
        let url = NSURL(string: "http://web.engr.illinois.edu/~svliu2/foodwithfriends/getInvites.php");
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        
        let postString = "userid=\(self.userid)"
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        // connect to server
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            // error handler
            if error != nil {
                println("CONNECTION ERROR:\(error)")
                return
            }
            // parse each element into an Event object
            var jsonArray = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: nil) as? Array<NSDictionary>
            
            if jsonArray != nil {
                let size = jsonArray!.count
                
                for i in 0...size-1 {
                    var jsonElement: NSDictionary = jsonArray![i]
                    var invite = Invite()
                    invite.event_id = jsonElement["event_id"] as! NSString;
                    invite.inviter_id = jsonElement["inviter_id"] as! NSString;

                    self.invites.addObject(invite)
                }
                
                if self.invites.count > 0 {
                    self.promptInvites()
                }
            }
        }
        task.resume()
    }
    
    // pop an invite from the downloaded list and make an alert to direct the user to the invited event
    func promptInvites() {
        var invite:Invite = invites[invites.count-1] as! Invite
        var inviter = NSString()
        var event_name = NSString()
        
        // find friend who invited the user
        for friend in self.friends {
            let friendname = friend.objectForKey("name") as! String
            let id = friend.objectForKey("id") as! String
            if id == invite.inviter_id {
                inviter = friendname
                break
            }
        }
        // find event user is invited to
        var ind = 0
        while ind < events.count-1 {
            if invite.event_id == events[ind].id {
                event_name = events[ind].name
                break
            }
            ind++
        }
        // remove the invite after processing it
        invites.removeObjectAtIndex(invites.count-1)
        
        // travel to the event the user was invited to
        index = ind
        
        let dismissHandler = {
            (action: UIAlertAction!) in
            self.performSegueWithIdentifier("seeEvent", sender: self)
        }
        
        // instantiate an alert message
        let alertController = UIAlertController(title: "YOU ARE INVITED!", message:
            "\(inviter) has invited you to \(event_name)", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: dismissHandler))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    //
    // Tableview Delegate Methods
    //

    // specify number of rows = number of events
    func tableView(tableViewEvents: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    // designate the height of each cell
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    // display event name for each cell
    func tableView(tableViewEvents: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell = self.tableViewEvents.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        
        cell.textLabel?.text = self.events[indexPath.row].name
        
        return cell
    }
    
    // segue into event details when cell is selected
    func tableView(tableViewEvents: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.index = indexPath.row
        
        // travel to view
        performSegueWithIdentifier("seeEvent", sender: self)
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "seeEvent" {
            var destController = segue.destinationViewController as! EventDetailController
            destController.event = self.events[self.index] as! Event
        }
    }
    

}
