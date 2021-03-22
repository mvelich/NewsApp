//
//  UIImageView+SetRounded.swift
//  NewsApp
//
//  Created by Maksim Velich on 21.03.21.
//

import UIKit

extension UIImageView {
    
    func setRounded() {
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.bounds.width / 2
    }
}
