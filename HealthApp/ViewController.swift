//
//  ViewController.swift
//  HealthApp
//
//  Created by Milton Leung on 2016-04-29.
//  Copyright © 2016 Milton Leung. All rights reserved.
//

import UIKit
import HealthKit
import CoreMotion

class ViewController: UIViewController {
    
    @IBOutlet weak var banner: UILabel!
    
    var healthManager:HealthManager?
    var firstDate: String = ""
    let pedometer = CMPedometer()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        healthManager = HealthManager()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "performLifetimeSegue:", name:"lifetimeNotification", object: nil)
        
        
        authorizeHealthKit()
        updateBanner()
    }
    
    func performLifetimeSegue(notification: NSNotification) {
        if let awards = notification.userInfo as? Dictionary<Int, Int> {
            let size = awards.count
            for index in 1 ... size {
                print(index)
                self.performSegueWithIdentifier("lifetimeSegue", sender: nil)
            }
        } else {
            print("error in userinfo type")
        }
    }
    
    @IBAction func achievementButton(sender: AnyObject) {
        //        self.performSegueWithIdentifier("lifetimeSegue", sender: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func authorizeHealthKit()
    {
        healthManager!.authorizeHealthKit { (authorized, error) -> Void in
            if authorized {
                print("HealthKit authorized")
                
            }
            else {
                print("HealthKit denied")
                if error != nil {
                    print("\(error)")
                }
            }
        }
    }
    
    func updateBanner() {
        
        if (CMPedometer.isStepCountingAvailable() && CMPedometer.isDistanceAvailable()) {
            let beginningOfDay = NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate(), options: [])
            self.pedometer.queryPedometerDataFromDate(beginningOfDay!, toDate: NSDate()) { (data : CMPedometerData?, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if error == nil {
                        if let distance = data?.distance {
                            
                            let currentBannerText = self.banner.text
                            self.banner.text = ModelInterface.sharedInstance.hardestHole(distance.doubleValue/1000)
                            
                            let achievementString = ModelInterface.sharedInstance.reachedAchievement(distance.integerValue/1000)
                            
                            if achievementString != currentBannerText {
                                self.banner.text = ModelInterface.sharedInstance.reachedAchievement(distance.integerValue/1000)
                            }
                            
                            
                            print(data?.distance)
                        }
                    }
                });
            }
            self.pedometer.startPedometerUpdatesFromDate(beginningOfDay!) { (data : CMPedometerData?, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let distance = data?.distance {
                        
                        let currentBannerText = self.banner.text
                        self.banner.text = ModelInterface.sharedInstance.hardestHole(distance.doubleValue/1000)
                        
                        let achievementString = ModelInterface.sharedInstance.reachedAchievement(distance.integerValue/1000)
                        
                        if achievementString != currentBannerText && achievementString != "" {
                            self.banner.text = ModelInterface.sharedInstance.reachedAchievement(distance.integerValue/1000)
                        }
                        
                        print(data?.distance)
                    }
                });
            }
        }
        
    }
    
    
}

