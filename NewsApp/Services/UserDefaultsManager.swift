//
//  UserDefaultManager.swift
//  NewsApp
//
//  Created by Maksim Velich on 2.04.21.
//

import Foundation

struct UserDefaultsManager {
    
    static func countUserSession() {
        let currentCount = UserDefaults.standard.integer(forKey: UserDefaults.AppSettings.StringDefaultKey.sessionNumber.rawValue)
        UserDefaults.standard.set(currentCount + 1, forKey: UserDefaults.AppSettings.StringDefaultKey.sessionNumber.rawValue)
    }
    
    static func sessionNumber() -> Int {
        return UserDefaults.standard.integer(forKey: UserDefaults.AppSettings.StringDefaultKey.sessionNumber.rawValue)
    }
    
    static func countScrollNumber() {
        let currentScrollNumber = UserDefaults.standard.integer(forKey: UserDefaults.AppSettings.StringDefaultKey.scrollNumber.rawValue)
        UserDefaults.standard.set(currentScrollNumber + 1, forKey: UserDefaults.AppSettings.StringDefaultKey.scrollNumber.rawValue)
    }
    
    static func scrollCounterNumber() -> Int {
        return UserDefaults.standard.integer(forKey: UserDefaults.AppSettings.StringDefaultKey.scrollNumber.rawValue)
    }
}
