//
//  EventCreateController.swift
//  Food with Friends
//
//  Created by Samuel Liu on 4/16/15.
//  Copyright (c) 2015 Samuel Liu. All rights reserved.
//

import UIKit

class EventCreateController: UIViewController {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var pickerDate: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pickerDate.minimumDate = NSDate()
        pickerDate.date = NSDate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    @IBAction func createTapped(sender: AnyObject) {
        println("tapped")
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var date = dateFormatter.stringFromDate(pickerDate.date)
        
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        var time = dateFormatter.stringFromDate(pickerDate.date)
        
        // send event data to server
        let url = NSURL(string: "http://web.engr.illinois.edu/~svliu2/foodwithfriends/saveEvent.php");
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        
        // get saved userid
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let userid:NSString = prefs.valueForKey("ID") as! NSString
        
        let postString = "userid=\(userid)&name=\(txtName.text)&location=\(txtLocation.text)&date=\(date)&time=\(time)"
        
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
    


}
