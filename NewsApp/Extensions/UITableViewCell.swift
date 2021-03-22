//
//  UITableViewCell.swift
//  NewsApp
//
//  Created by Maksim Velich on 21.03.21.
//

import UIKit

extension UITableViewCell{

    var tableView: UITableView? {
        return superview as? UITableView
    }

    var indexPath: IndexPath? {
        return tableView?.indexPath(for: self)
    }
}
