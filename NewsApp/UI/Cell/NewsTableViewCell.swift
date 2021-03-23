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
    
    func updateCell(with news: News) {
        let url = news.image
        if url == nil {
            self.newsImageView.image = UIImage(named: "default_news_image")
        } else {
            self.newsImageView.kf.setImage(with: url, placeholder: UIImage(named: "default_news_image"))
        }
        
        self.titleTextLabel.text = news.title ?? "*No title*"
        self.descriptionTextLabel.text = news.newsDescription ?? "*No description*"
        if self.descriptionTextLabel!.isTruncated() || self.descriptionTextLabel.countLabelLines() > 3 {
            self.showMoreLessButton.isHidden = false
        } else {
            self.showMoreLessButton.isHidden = true
        }
         
        self.descriptionTextLabel.numberOfLines = news.isOpen ? 0 : 3
        self.showMoreLessButton.setTitle(news.isOpen ? "Show Less" : "Show More", for: .normal)
    }
}

