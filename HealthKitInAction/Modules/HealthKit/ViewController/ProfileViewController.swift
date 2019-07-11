//
//  ProfileViewController.swift
//  HealthKitInAction
//
//  Created by 徐岚 on 2019/7/11.
//  Copyright © 2019 BetaTiger. All rights reserved.
//

import UIKit
import HealthKit

class ProfileViewController: UITableViewController {
    
    private enum ProfileSection: Int {
        case ageSexBloodType
        case weightHeightBMI
        case readHealthKitData
        case saveBMI
    }
    
    private enum ProfileDataError: Error {
        case missingBodyMassIndex
        
        var localizedDescription: String {
            switch self {
            case .missingBodyMassIndex:
                return "Unable to calculate body mass index with available profile data."
            }
        }
    }
    
    @IBOutlet private var weightLabel:UILabel!
    @IBOutlet private var heightLabel:UILabel!
    @IBOutlet private var bodyMassIndexLabel:UILabel!
    
    @IBOutlet private var ageLabel:UILabel!
    @IBOutlet private var biologicalSexLabel:UILabel!
    @IBOutlet private var bloodTypeLabel:UILabel!
    

    
    private let userHealthProfile = UserHealthProfile()
    
    override func viewWillAppear(_ animated: Bool) {
        updateHealthInfo()
    }
    
    private func updateHealthInfo() {
        loadAndDisplayAgeSexAndBloodType()
        loadAndDisplayMostRecentWeight()
        loadAndDisplayMostRecentHeight()
    }
    
    private func loadAndDisplayAgeSexAndBloodType() {
        do {
            let userAgeSexAndBloodType = try ProfileDataStore.getAgeSexAndBloodType()
            userHealthProfile.age = userAgeSexAndBloodType.age
            userHealthProfile.bloodType = userAgeSexAndBloodType.bloodType
            userHealthProfile.biologicalSex = userAgeSexAndBloodType.biologicalSex
            updateLabels()
        } catch let error {
            self.displayAlert(for: error)
        }
    }
    
    private func updateLabels() {
        if let age = userHealthProfile.age {
            ageLabel.text = "\(age)"
        }
        
        if let biologicalSex = userHealthProfile.biologicalSex {
            biologicalSexLabel.text = biologicalSex.stringRepresentation
        }
        
        if let bloodType = userHealthProfile.bloodType {
            print("bloodTyp:\(bloodType.stringRepresentation)")
            bloodTypeLabel.text = bloodType.stringRepresentation
        }
        
        if let weight = userHealthProfile.weightInKilograms {
            let weightFormatter = MassFormatter()
            weightFormatter.isForPersonMassUse = true
            weightLabel.text = weightFormatter.string(fromKilograms: weight)
        }
        
        if let height = userHealthProfile.heightInMeters {
            let heightFormatter = LengthFormatter()
            heightFormatter.isForPersonHeightUse = true
            heightLabel.text = heightFormatter.string(fromMeters: height)
        }
        
        if let bodyMassIndex = userHealthProfile.bodyMassIndex {
            bodyMassIndexLabel.text = String(format: "%.02f", bodyMassIndex)
        }
    }
    
    private func loadAndDisplayMostRecentHeight() {
        guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
            print("Height Sample Type is no longer available in HealthKit")
            return
        }
        
        ProfileDataStore.getMostRecentSample(for: heightSampleType) { (sample, error) in
            guard let sample = sample else {
                if let error = error {
                    self.displayAlert(for: error)
                }
                
                return
            }
            
            let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
            self.userHealthProfile.heightInMeters = heightInMeters
            self.updateLabels()
        }
    }
    
    private func loadAndDisplayMostRecentWeight() {
        guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            print("Body Mass Sample Type is no longer available in HealthKit")
            return
        }
        
        ProfileDataStore.getMostRecentSample(for: weightSampleType) { (sample, error) in
            guard let sample = sample else {
                if let error = error {
                    self.displayAlert(for: error)
                }
                
                return
            }
            
            let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            self.userHealthProfile.weightInKilograms = weightInKilograms
            self.updateLabels()
        }
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
}
