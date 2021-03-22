//
//  NewsData.swift
//  NewsApp
//
//  Created by Maksim Velich on 21.03.21.
//

import Foundation

struct NewsData: Codable {
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable {
    let title: String?
    let description: String?
    let urlToImage: URL?
}
