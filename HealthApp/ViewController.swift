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
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var today: UILabel!
    @IBOutlet weak var todayDistance: UILabel!
    @IBOutlet weak var totalDistance: UILabel!
    @IBOutlet weak var pedometerSteps: UILabel!
    var steps, distance:HKQuantitySample?
    var stepsDictionary = [String: HKQuantity]()
    var distanceDictionary = [String: HKQuantity]()
    var healthManager:HealthManager?
    let pedometer = CMPedometer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        healthManager = HealthManager()
        
        
        authorizeHealthKit()
        self.updatePedometer()
        
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
                self.today.text = "0"
                self.todayDistance.text = "0"
                self.updateTotalSteps()
                self.updateTotalDistance()
                self.updateSteps()
                self.updateDistance()
                
            }
            else {
                print("HealthKit denied")
                if error != nil {
                    print("\(error)")
                }
            }
        }
    }
    
    func updateSteps() {
        
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        
        self.healthManager?.readRecentSample(sampleType!, recentData: &stepsDictionary, completion: { (mostRecentSteps, error) -> Void in
            if (error != nil) {
                print("Error reading steps from HealthKit")
                return;
            }
            
            for (dates, quantity) in mostRecentSteps {
                print("\(dates): \(quantity)")
            }
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let str = dateFormatter.stringFromDate(NSDate())
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let currentSteps = mostRecentSteps[str] {
                    self.today.text = "today's steps: \(currentSteps)"
                    print(self.today.text!)
                }
            });
        });
    }
    
    func updateDistance() {
        
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
        
        self.healthManager?.readRecentSample(sampleType!, recentData: &distanceDictionary, completion: { (mostRecentDistance, error) -> Void in
            
            if (error != nil) {
                print("Error reading distance from HealthKit")
                return;
            }
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let str = dateFormatter.stringFromDate(NSDate())
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let currentDoubleDistance = mostRecentDistance[str] {
                    let currentIntDistance = Int(currentDoubleDistance.doubleValueForUnit(HKUnit.meterUnitWithMetricPrefix(.Kilo)))
                    self.todayDistance.text = "today's distance: \(currentIntDistance)"
                    print(self.todayDistance.text!)
                }
            });
        });
    }
    
    func updateTotalSteps() {
        let stepsCount = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        
        self.healthManager?.readTotalSample(stepsCount!, completion: { (totalSteps, error) -> Void in
            if (error != nil) {
                print("Error reading total steps from HealthKit")
                return;
            }
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let totalResult = Int(totalSteps.1.doubleValueForUnit(HKUnit.countUnit()))
                self.label.text = "total steps: \(totalResult) since \(totalSteps.0)"
                print(self.label.text!)
            });
        });
    }
    func updateTotalDistance() {
        let distanceType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
        
        self.healthManager?.readTotalSample(distanceType!, completion: { (totalDistance, error) -> Void in
            if (error != nil) {
                print("Error reading total distance from HealthKit")
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let totalResult = Int(totalDistance.1.doubleValueForUnit(HKUnit.meterUnitWithMetricPrefix(.Kilo)))
                self.totalDistance.text = "total distance: \(totalResult) since \(totalDistance.0)"
                print(self.totalDistance.text!)
            });
        });
    }
    
    func updatePedometer() {
        
        if (CMPedometer.isStepCountingAvailable()) {
            let beginningOfDay = NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate(), options: [])
            self.pedometer.queryPedometerDataFromDate(beginningOfDay!, toDate: NSDate()) { (data : CMPedometerData?, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if error == nil {
                        if let numberOfSteps = data?.numberOfSteps {
                            self.pedometerSteps.text = "\(numberOfSteps)"
                            print(data?.numberOfSteps)
                        }
                    }
                });
            }
            self.pedometer.startPedometerUpdatesFromDate(beginningOfDay!) { (data : CMPedometerData?, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let numberOfSteps = data?.numberOfSteps {
                        self.pedometerSteps.text = "\(numberOfSteps)"
                        print(data?.numberOfSteps)
                    }
                });
            }
        }
        
    }
}
