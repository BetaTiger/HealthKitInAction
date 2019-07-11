//
//  DailyTableViewController.swift
//  HealthKitInAction
//
//  Created by 徐岚 on 2019/7/11.
//  Copyright © 2019 BetaTiger. All rights reserved.
//

import UIKit
import HealthKit

class DailyTableViewController: UITableViewController {

    @IBOutlet weak var waterConsumedLabel: UILabel!
    @IBOutlet weak var stepsTakenLabel: UILabel!
    @IBOutlet weak var flightsClimbedLabel: UILabel!
    
    override func viewDidLoad() {
        
       NotificationCenter.default.addObserver(self, selector: #selector(updateMyDayInfo), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateMyDayInfo()
    }
    
    @objc private func updateMyDayInfo() {
        
        loadAndDisplayStepsTaken()
        loadAndDisplayFlightsClimbed()
        loadAndDisplayDailyWaterConsumed()
    }
    
    private func displayAlert(for error: Error) {
        
        let alert = UIAlertController(title: nil,
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func loadAndDisplayStepsTaken() {
        
        guard let stepsTakenType = HKSampleType.quantityType(forIdentifier: .stepCount) else {
            print("Steps Count Type is no longer available in HealthKit")
            return
        }
        
        ProfileDataStore.queryQuantitySum(for: stepsTakenType, unit: HKUnit.count() ) { (sampleTotal, error) in
            
            guard let sample = sampleTotal else {
                
                if let error = error {
                    self.displayAlert(for: error)
                }
                DispatchQueue.main.async{self.stepsTakenLabel.text = "N/A"}
                return
            }
            
            DispatchQueue.main.async{self.stepsTakenLabel.text = "\(Int(sample))"}
        }
    }
    
    private func loadAndDisplayFlightsClimbed() {
        
        guard let flightsClimbedType = HKSampleType.quantityType(forIdentifier: .flightsClimbed) else {
            print("Flights Climbed Type is no longer available in HealthKit")
            return
        }
        
        ProfileDataStore.queryQuantitySum(for: flightsClimbedType, unit: HKUnit.count()) { (sampleTotal, error) in
            guard let sample = sampleTotal else {
                if let error = error {
                    self.displayAlert(for: error)
                }
                DispatchQueue.main.async{self.flightsClimbedLabel.text = "N/A"}
                return
            }
            
            DispatchQueue.main.async{self.flightsClimbedLabel.text = "\(Int(sample))"}
        }
    }
    
    private func loadAndDisplayDailyWaterConsumed() {
        
        guard let waterConsumedType = HKSampleType.quantityType(forIdentifier: .dietaryWater) else {
            print("Dietary Water Type is no longer available in HealthKit")
            return
        }
        
        ProfileDataStore.queryQuantitySum(for: waterConsumedType, unit:HKUnit.literUnit(with: .milli)) { (sampleTotal, error) in
            
            guard let sample = sampleTotal else {
                if let error = error {
                    self.displayAlert(for: error)
                }
                DispatchQueue.main.async{self.waterConsumedLabel.text = "N/A"}
                return
            }
            
            let waterInOunces = sample
            let formatted = String(format: "%.2f", waterInOunces)
            DispatchQueue.main.async{self.waterConsumedLabel.text = formatted}
        }
    }
}
