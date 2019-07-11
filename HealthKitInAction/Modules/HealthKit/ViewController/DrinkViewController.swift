//
//  DrinkViewController.swift
//  HealthKitInAction
//
//  Created by 徐岚 on 2019/7/11.
//  Copyright © 2019 BetaTiger. All rights reserved.
//

import UIKit
import HealthKit
class DrinkViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var waterConsumedInputField: UITextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

    @IBAction func saveConsumedWater(_ sender: UIButton) {
        saveWaterConsumedToHealthKit()
        waterConsumedInputField.text = ""
    }
    
    override func becomeFirstResponder() -> Bool {

        super.becomeFirstResponder()
        
        return waterConsumedInputField.becomeFirstResponder()
    }
    
    
    private enum WaterInputDataError: Error {
        
        case missingWaterConsumed
        case invalidValue
        
        var localizedDescription: String {
            switch self {
            case .missingWaterConsumed:
                return "Unable to save water consumed - no value entered."
            case .invalidValue:
                return "Unable to save water consumed - invalid value entered."
            }
        }
    }
    
    private func displayAlert(for error: WaterInputDataError) {
        
        print("error is \(error)")
        let alert = UIAlertController(title: nil,
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func saveWaterConsumedToHealthKit() {
        
        guard let waterConsumed = waterConsumedInputField.text else {
            displayAlert(for: WaterInputDataError.missingWaterConsumed)
            return
        }
        
        guard let waterConsumedValue = Double(waterConsumed) else
        {
            displayAlert(for: WaterInputDataError.invalidValue)
            return
        }
        
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            fatalError("Dietary Water Type is no longer available in HealthKit")
        }
        
         ProfileDataStore.saveSample(value: waterConsumedValue, unit: HKUnit.literUnit(with: .milli), type: waterType, date: Date())
    }

}
