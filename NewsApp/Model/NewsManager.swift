//
//  NewsManager.swift
//  NewsApp
//
//  Created by Maksim Velich on 21.03.21.
//

import UIKit
import Alamofire
import CoreData

class NewsManager {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var newsArray = [News]()
    private let apiKey = "300710d6dda3421e99bba57ecafb438c"
    
    func performRequest(refreshData: Bool, counter: Int, completion: @escaping () -> Void) {
        let httpRequest = buildRequest(counter: counter)
        AF.request(httpRequest).responseJSON { response in
            guard let responseData = response.data else { return }
            switch (response.result) {
            case .success( _):
                if refreshData {
                    self.clearNewsData()
                    self.parseJSON(responseData)
                } else {
                    self.parseJSON(responseData)
                }
                completion()
            case .failure(let error):
                print("Request error: \(error.localizedDescription)")
            }
        }
    }
    
    private func parseJSON(_ newsData: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedNewsData = try decoder.decode(NewsData.self, from: newsData)
            for newsItem in decodedNewsData.articles {
                let news = News(context: self.context)
                news.image = newsItem.urlToImage ?? nil
                news.title = newsItem.title
                news.newsDescription = newsItem.description
                news.publishTime = dateConverter(with: newsItem.publishedAt)
            }
            do {
                try self.context.save()
            } catch let dbError as NSError {
                print("Unexpected error during saving data: \(dbError).")
            }
        } catch let jsonError as NSError{
            print("Unexpected error during JSON parsing: \(jsonError).")
        }
    }
    
    private func buildRequest(counter: Int) -> String {
        // Build date for request based on scrollCounter value
        let rightDate = Calendar.current.date(byAdding: .day, value: -counter, to: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let resultDate = formatter.string(from: rightDate!)
        let resultRequest = "https://newsapi.org/v2/everything?q=IOS&language=en&pageSize=10&from=\(resultDate)&to=\(resultDate)&sortBy=publishedAt&apiKey=\(apiKey)"
        return resultRequest
    }
    
    private func dateConverter(with stringDate: String?) -> Date? {
        guard let stringDate = stringDate else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"
        let date = dateFormatter.date(from: stringDate)
        return date
    }
    
    func clearNewsData() {
        do {
            let dataAray = try context.fetch(News.fetchRequest())
            for news in dataAray {
                context.delete(news as! NSManagedObject)
            }
            try self.context.save()
        } catch let dbError as NSError {
            print("Unexpected error during deleting data: \(dbError).")
        }
    }
}
