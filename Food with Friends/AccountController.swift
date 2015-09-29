//
//  AccountController.swift
//  Food with Friends
//
//  Created by Samuel Liu on 4/20/15.
//  Copyright (c) 2015 Samuel Liu. All rights reserved.
//

import UIKit

class AccountController: UIViewController, FBLoginViewDelegate {

    
    @IBOutlet weak var fbLoginView: FBLoginView!
    @IBOutlet weak var fbProPicView: FBProfilePictureView!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.fbLoginView.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Facebook Delegate Methods
    
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        
        fbProPicView.profileID = user.objectID
        
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!){
        
        FBSession.activeSession().closeAndClearTokenInformation()
        
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    
}
