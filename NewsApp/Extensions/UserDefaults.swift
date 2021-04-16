//
//  UserDefaults.swift
//  NewsApp
//
//  Created by Maksim Velich on 4.04.21.
//

import Foundation

extension UserDefaults {
    struct AppSettings {
        enum StringDefaultKey: String {
            case sessionNumber
            case scrollNumber
        }
    }
}
