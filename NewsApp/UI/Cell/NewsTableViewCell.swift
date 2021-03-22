//
//  NewsTableViewCell.swift
//  NewsApp
//
//  Created by Maksim Velich on 21.03.21.
//

import UIKit

protocol CustomCellDelegate {
    func didPressShowButton(_ cell: NewsTableViewCell)
}

class NewsTableViewCell: UITableViewCell {
    
    var customCellDelegate: CustomCellDelegate?
    
    @IBOutlet weak var newsImageView: UIImageView! {
        didSet {
            newsImageView.setRounded()
        }
    }
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var descriptionTextLabel: UILabel!
    @IBOutlet weak var showMoreLessButton: UIButton!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func showMoreLessButtonPressed(_ sender: UIButton) {        
        customCellDelegate?.didPressShowButton(self)
    }
}

