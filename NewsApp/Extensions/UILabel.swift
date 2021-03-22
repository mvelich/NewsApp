//
//  UILabel.swift
//  NewsApp
//
//  Created by Maksim Velich on 21.03.21.
//

import UIKit

extension UILabel {
    
    func countLabelLines() -> Int {
        let myText = self.text! as NSString
        let attributes = [NSAttributedString.Key.font : self.font]
        
        let labelSize = myText.boundingRect(with: CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
        return Int(ceil(CGFloat(labelSize.height) / self.font.lineHeight))
    }
    
    func isTruncated() -> Bool {
        guard numberOfLines > 0 else { return false }
        return countLabelLines() > numberOfLines
    }
}
