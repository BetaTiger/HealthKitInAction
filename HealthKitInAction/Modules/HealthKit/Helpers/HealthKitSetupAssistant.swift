//
//  HealthKitSetupAssistant.swift
//  HealthKitInAction
//
//  Created by 徐岚 on 2019/7/11.
//  Copyright © 2019 BetaTiger. All rights reserved.
//

import HealthKit

class HealthKitSetupAssistant {
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        guard  let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
            let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
            let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
            let height = HKObjectType.quantityType(forIdentifier: .height),
            let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
            let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            let steps = HKObjectType.quantityType(forIdentifier: .stepCount),
            let flights = HKObjectType.quantityType(forIdentifier: .flightsClimbed),
            let water = HKObjectType.quantityType(forIdentifier: .dietaryWater)
            else {

                completion(false, HealthkitSetupError.dataTypeNotAvailable)
                return
        }
        
        let healthKitTypesToWrite: Set<HKSampleType> = [bodyMassIndex,activeEnergy,water]
        
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
                                                       bloodType,
                                                       biologicalSex,
                                                       bodyMassIndex,
                                                       height,
                                                       bodyMass,
                                                       steps,
                                                       flights,
                                                       water]
        
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) in
            completion(success,error)
        }
    }
    
}
