//
//  ViewController.swift
//  Food with Friends
//
//  Created by Samuel Liu on 2/5/15.
//  Copyright (c) 2015 Samuel Liu. All rights reserved.
//

import UIKit
import QuartzCore

class LoginController: UIViewController, FBLoginViewDelegate {
    @IBOutlet weak var fbLoginView: FBLoginView!
    @IBOutlet weak var fbProPicView: FBProfilePictureView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var btnContinue: UIButton!

    
    @IBAction func continuePressed(sender: UIButton) {
            performSegueWithIdentifier("loggedIn", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.lblUsername.hidden = true
        btnContinue.hidden = true
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
    }
    
    //Facebook Delegate Methods
    
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        btnContinue.hidden = false
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        self.lblUsername.hidden = false
        lblUsername.text = user.name
        fbProPicView.profileID = user.objectID
        
        let userID = user.objectID
        var username = user.name
        var useremail = user.objectForKey("email") as! String
        
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()

        
        // Get List Of Friends
        var friendsRequest : FBRequest = FBRequest.requestForMyFriends()
        friendsRequest.startWithCompletionHandler
            {
                (connection:FBRequestConnection!,   result:AnyObject!, error:NSError!) -> Void in
                var resultdict = result as! NSDictionary
                println("Result Dict: \(resultdict)")
                var data : NSArray = resultdict.objectForKey("data") as! NSArray
                
                for i in 0 ..< data.count
                {
                    let valueDict : NSDictionary = data[i] as! NSDictionary
                    let id = valueDict.objectForKey("id") as! String
                }
                
                var friends = resultdict.objectForKey("data") as! NSArray
                println("Found \(friends.count) friends")
                
                // extract friend IDs into a separate array
                var friendids = NSMutableArray()
                for friend in friends
                {
                    friendids.addObject(friend.objectForKey("id") as! NSString)
                }
                
                // save friends list on device storage
                prefs.setObject(friends, forKey: "FRIENDS")
                prefs.setObject(friendids, forKey: "FRIENDIDS")

        }
        
        

        
        // send user data to server
        var url = NSURL(string: "http://web.engr.illinois.edu/~svliu2/foodwithfriends/login.php")!
        
        var post = "userid=\(userID)&email=\(useremail)"
        
        NSLog("PostData: %@",post)
        
        var request = NSMutableURLRequest(URL:url)
        request.HTTPMethod = "POST"
        request.HTTPBody = post.dataUsingEncoding(NSUTF8StringEncoding)
        
        var responseError: NSError?
        var response: NSURLResponse?
        
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&responseError)
        
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!
            
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                
                var error: NSError?
                
                let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                
                let success:NSString = jsonData.valueForKey("status") as! NSString
                
                NSLog("Status: %@", success)
                
                if(success == "Success")
                {
                    NSLog("Sign Up SUCCESS");
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    url = NSURL(string: "http://web.engr.illinois.edu/~svliu2/foodwithfriends/register.php")!
                    
                    post = "userid=\(userID)&email=\(useremail)"
                    
                    NSLog("Registering.. %@", post)
                    
                    request = NSMutableURLRequest(URL:url)
                    request.HTTPMethod = "POST"
                    request.HTTPBody = post.dataUsingEncoding(NSUTF8StringEncoding)
                    
                    var responseError: NSError?
                    var response: NSURLResponse?
                    
                    var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&responseError)
                    
                    if ( urlData != nil ) {
                        let res = response as! NSHTTPURLResponse!
                        
                        if (res.statusCode >= 200 && res.statusCode < 300)
                        {
                            var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                            
                            var error: NSError?
                            
                            let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                            
                            let success:NSString = jsonData.valueForKey("status") as! NSString
                            
                            NSLog("Status: %@", success)
                            
                            if(success == "Success")
                            {
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        
        prefs.setObject(username, forKey: "NAME")
        prefs.setObject(userID, forKey: "ID")
        prefs.setInteger(1, forKey: "ISLOGGEDIN")
        prefs.synchronize()

    }

    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!){
        FBSession.activeSession().closeAndClearTokenInformation()
        fbProPicView.profileID = nil
        lblUsername.text = ""
        btnContinue.hidden = true
        
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
    }
    
    func loginView(loginView: FBLoginView!, handleError:NSError){
        println("Error: \(handleError.localizedDescription)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

