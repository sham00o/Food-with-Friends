//
//  EventDetailController.swift
//  Food with Friends
//
//  Created by Samuel Liu on 4/16/15.
//  Copyright (c) 2015 Samuel Liu. All rights reserved.
//

import UIKit

class EventDetailController: UIViewController {

    var event = Event()
    var attendees = NSMutableArray()
    
    let userid:NSString = NSUserDefaults.standardUserDefaults().valueForKey("ID") as! NSString
    
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblCreator: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var swAttend: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnDelete.hidden = true
        swAttend.setOn(false, animated:false)
        
        swAttend.addTarget(self, action: Selector("stateChanged:"), forControlEvents: UIControlEvents.ValueChanged)

        // Set backend data onto the view labels
        
        lblStatus.text = "YOU ARE NOT GOING"
        lblCreator.text = event.creator_name as String
        lblName.text = event.name as String
        lblLocation.text = event.location as String
        lblDate.text = event.date as String
        lblTime.text = event.time as String
        
        // check if event is user's to determine whether user can delete event
        
        if userid == event.creator_id {
            btnDelete.hidden = false
        }
        
        // get list of attendee's for current event into attendeesArr
        getInvited()

    }
    
    func getInvited() {
        
        // reset list of attendees
        attendees = NSMutableArray()
        
        let url = NSURL(string: "http://web.engr.illinois.edu/~svliu2/foodwithfriends/getInvited.php")
        let request = NSMutableURLRequest(URL:url!)
        
        request.HTTPMethod = "POST"
        
        let postString = "eventid=\(event.id)"
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, request, error in
            
            // error handler
            if error != nil {
                println("Connection error=\(error)")
                return
            }
            var err:NSError?

            // parse JSON response from server

            var jsonArray = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: &err) as? Array<NSDictionary>
            
            if jsonArray != nil {
                
                let size = jsonArray!.count
                
                for i in 0...size-1 {
                    var jsonElement: NSDictionary = jsonArray![i]
                    self.attendees.addObject(jsonElement["user_id"] as! NSString)
                }
                
                // check for user id in the attendance list
                for user in self.attendees {
                    if self.userid == user as! NSString {
                        // call main thread to update status label
                        dispatch_async(dispatch_get_main_queue(), {
                            self.lblStatus.text = "YOU ARE GOING"
                            self.swAttend.setOn(true, animated:true)
                            return
                        })
                    }
                }
                
            }
        }
        
        task.resume()

    }
    
    @IBAction func backTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Send event_id to server and delete from database
    @IBAction func deleteTapped(sender: AnyObject) {
        
        let url = NSURL(string: "http://web.engr.illinois.edu/~svliu2/foodwithfriends/deleteEvent.php")
        
        // prepare POST request to server
        let request = NSMutableURLRequest(URL:url!)
        
        request.HTTPMethod = "POST"
        
        let postString = "eventid=\(event.id)"
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, request, error in
            
            // error handler
            if error != nil {
                println("Connection error=\(error)")
                return
            }
            var err:NSError?
            var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err)
            
            // parse JSON response from server
            if let parseJSON: AnyObject = json {
                var resultValue:String = parseJSON["status"] as! String
                var resultMsg:String = parseJSON["message"] as! String
                println("result:\(resultValue)")
                println("message:\(resultMsg)")
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    
        task.resume()
        
    }
    
    // switch state handler
    func stateChanged(switchState: UISwitch) {
        if switchState.on {
            going()
        } else {
            notGoing()
        }
    }
    
    func going(){
        
        let url = NSURL(string: "http://web.engr.illinois.edu/~svliu2/foodwithfriends/goingEvent.php")
        
        // prepare POST request to server
        let request = NSMutableURLRequest(URL:url!)
        
        request.HTTPMethod = "POST"
        
        let postString = "eventid=\(event.id)&userid=\(userid)"
        
        println("post: \(postString)")
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, request, error in
            
            // error handler
            if error != nil {
                println("Connection error=\(error)")
                return
            }
            var err:NSError?
            var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err)
            
            // parse JSON response from server
            if let parseJSON: AnyObject = json {
                var resultValue:String = parseJSON["status"] as! String
                var resultMsg:String = parseJSON["message"] as! String
                println("result:\(resultValue)")
                println("message:\(resultMsg)")
                
                // call main thread to update status label
                dispatch_async(dispatch_get_main_queue(), {
                    self.getInvited()
                    return
                })
            }
        }
        
        task.resume()
    }
    
    func notGoing(){
        
        let url = NSURL(string: "http://web.engr.illinois.edu/~svliu2/foodwithfriends/notGoingEvent.php")
        
        // prepare POST request to server
        let request = NSMutableURLRequest(URL:url!)
        
        request.HTTPMethod = "POST"
        
        let postString = "eventid=\(event.id)&userid=\(userid)"
        
        println("post: \(postString)")
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, request, error in
            
            // error handler
            if error != nil {
                println("Connection error=\(error)")
                return
            }
            var err:NSError?
            var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err)
            
            // parse JSON response from server
            if let parseJSON: AnyObject = json {
                var resultValue:String = parseJSON["status"] as! String
                var resultMsg:String = parseJSON["message"] as! String
                println("result:\(resultValue)")
                println("message:\(resultMsg)")
                
                // call main thread to update status label
                dispatch_async(dispatch_get_main_queue(), {
                    self.getInvited()
                    self.lblStatus.text = "YOU ARE NOT GOING"
                    self.swAttend.setOn(false, animated:true)
                })
            }
        }
        
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if segue.identifier == "toInvite" {
            var destController = segue.destinationViewController as! InviteController
            destController.attendees = self.attendees as NSArray
            destController.event = self.event
        }
    }

}
