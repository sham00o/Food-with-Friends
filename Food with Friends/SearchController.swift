//
//  SearchController.swift
//  Food with Friends
//
//  Created by Samuel Liu on 4/21/15.
//  Copyright (c) 2015 Samuel Liu. All rights reserved.
//

import UIKit

class SearchController: UIViewController {
    
    var friends = NSMutableArray()
    var index = NSInteger()

    @IBOutlet weak var tableViewFriends: UITableView!
    
    override func viewDidAppear(animated: Bool) {
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        friends = prefs.valueForKey("FRIENDS") as! NSMutableArray
        println("Found \(friends.count) friends")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    // Tableview Delegate Methods
    //
    
    // specify number of rows = number of events
    func tableView(tableViewEvents: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    // designate the height of each cell
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    // display event name for each cell
    func tableView(tableViewFriends: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell = self.tableViewFriends.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        
        cell.textLabel?.text = self.friends[indexPath.row].name
        
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
        
        var destController = segue.destinationViewController as! EventDetailController
        destController.event = self.friends[self.index] as! Event
    }
    

}
