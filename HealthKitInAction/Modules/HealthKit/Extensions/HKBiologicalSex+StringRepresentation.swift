//
//  HKBiologicalSex+StringRepresentation.swift
//  HealthKitInAction
//
//  Created by 徐岚 on 2019/7/11.
//  Copyright © 2019 BetaTiger. All rights reserved.
//

import HealthKit

extension HKBiologicalSex {
    
    var stringRepresentation: String {
        switch self {
        case .notSet: return "Unknown"
        case .female: return "Female"
        case .male: return "Male"
        case .other: return "Other"
        @unknown default:
            fatalError()
        }
    }
}
