//
//  ProfileDataStore.swift
//  HealthKitInAction
//
//  Created by 徐岚 on 2019/7/11.
//  Copyright © 2019 BetaTiger. All rights reserved.
//

import HealthKit
import QMUIKit

class ProfileDataStore {
    
    class func getAgeSexAndBloodType() throws -> (age: Int,
        bloodType: HKBloodType,
        biologicalSex: HKBiologicalSex) {
            
            let healthKitStore = HKHealthStore()
            
            do {
                
                //This method throws an error if these data are not available.
                let birthdayComponents =  try healthKitStore.dateOfBirthComponents()
                let bloodType =           try healthKitStore.bloodType()
                let biologicalSex =       try healthKitStore.biologicalSex()
                
                //Use Calendar to calculate age.
                let today = Date()
                let calendar = Calendar.current
                
                let birthDay = calendar.date(from: birthdayComponents)
                let ageComponents = calendar.dateComponents([.year], from: birthDay!, to: today)
                
                //Unwrap the wrappers to get the underlying enum values.
                let unwrappedBloodType = bloodType.bloodType
                let unwrappedBiologicalSex = biologicalSex.biologicalSex
                
                //3. Add the sex to the tuple to return
                return (ageComponents.year!, unwrappedBloodType, unwrappedBiologicalSex)
            }
    }
    
    class func saveSample(value:Double, unit:HKUnit, type: HKQuantityType, date:Date)
    {
        let quantity = HKQuantity(unit: unit, doubleValue: value)
        let sample = HKQuantitySample(type: type,
                                      quantity: quantity,
                                      start: date,
                                      end: date)
        
        HKHealthStore().save(sample) { (success, error) in
            guard let error = error else {
                print("Successfully saved \(type)");
                DispatchQueue.main.async {
                    QMUITips.showSucceed("Successfully saved \(type)")
                }
                return
            }
            
            print("Error saving \(type) \(error.localizedDescription)")
            DispatchQueue.main.async {
                QMUITips.showInfo("Error saving \(type) \(error.localizedDescription)")
            }
        }
    }
    
    class func queryQuantitySum(for quantityType:HKQuantityType, unit:HKUnit,
                                completion: @escaping (Double?, Error?) -> Void) {
        
        guard let startDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: Date())) else {
            fatalError("Failed to strip time from Date object")
        }
        let endDate = Date()
        
        let sumOption = HKStatisticsOptions.cumulativeSum
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let statisticsSumQuery = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: sumOption) {
            (query, result, error) in
            if let sumQuantity = result?.sumQuantity() {
                DispatchQueue.main.async {
                    let total = sumQuantity.doubleValue(for: unit)
                    completion(total, nil)
                }
            }
            else
            {
                print("no sum quantity")
                completion(nil, error)
            }
        }
        HKHealthStore().execute(statisticsSumQuery)
    }
    
    
    class func getMostRecentSample(for sampleType: HKSampleType,
                                   completion: @escaping (HKQuantitySample?, Error?) -> ()) {
        
        //1. Use HKQuery to load the most recent samples.
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        
        let limit = 1
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: mostRecentPredicate,
                                        limit: limit,
                                        sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                                            DispatchQueue.main.async {
                                                guard let samples = samples,
                                                    let mostRecentSample = samples.first as? HKQuantitySample else {
                                                        completion(nil, error)
                                                        return
                                                }
                                                
                                                completion(mostRecentSample, nil)
                                            }
        }
        
        HKHealthStore().execute(sampleQuery)
    }
}
