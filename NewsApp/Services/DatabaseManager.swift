//
//  DatabaseManager.swift
//  NewsApp
//
//  Created by Maksim Velich on 29.03.21.
//

import UIKit
import CoreData

class DatabaseManager {
    
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    lazy var networkManager = NetworkManager()
    
    func cleanNewsDB() {
        do {
            let dataAray = try context.fetch(News.fetchRequest())
            for news in dataAray {
                context.delete(news as! NSManagedObject)
            }
            try context.save()
        } catch let dbError as NSError {
            print("Unexpected error during deleting data: \(dbError).")
        }
    }
    
    func fetchNewsFromDB(to newsArray: inout [News], completion: @escaping () -> Void) {
        newsArray.removeAll()
        let fetchRequest = NSFetchRequest<News>(entityName: "News")
        let sort = NSSortDescriptor(key: #keyPath(News.publishTime), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        do {
            newsArray = try context.fetch(fetchRequest)
        } catch let dbError as NSError {
            print("Unexpected error during retrieving data: \(dbError).")
        }
        completion()
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch let dbError as NSError {
            print("Unexpected error during saving data: \(dbError).")
        }
    }
    
    func fetchNewsData(with decodedNewsData: NewsData) {
        for newsItem in decodedNewsData.articles {
            let news = News(context: context)
            news.image = newsItem.urlToImage ?? nil
            news.title = newsItem.title
            news.newsDescription = newsItem.description
            news.publishTime = DateHelper.convertStringToDate(with: newsItem.publishedAt)
        }
        saveContext()
    }
}
