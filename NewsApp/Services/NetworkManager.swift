//
//  NewsManager.swift
//  NewsApp
//
//  Created by Maksim Velich on 21.03.21.
//

import UIKit
import Alamofire

class NetworkManager {
    
    private let databaseManager = DatabaseManager()
    private let apiKey = "300710d6dda3421e99bba57ecafb438c"
    
    func performRequest(refreshData: Bool, counter: Int, completion: @escaping () -> Void) {
        let actualDate = DateHelper.dateCounter(counter: counter)
        let url = "https://newsapi.org/v2/everything?q=IOS&language=en&pageSize=10&from=\(actualDate)&to=\(actualDate)&sortBy=publishedAt&apiKey=\(apiKey)"
        AF.request(url).responseJSON { response in
            guard let responseData = response.data else { return }
            switch (response.result) {
            case .success( _):
                if refreshData {
                    self.databaseManager.cleanNewsDB()
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
            databaseManager.fetchNewsData(with: decodedNewsData)
        } catch let jsonError as NSError{
            print("Unexpected error during JSON parsing: \(jsonError).")
        }
    }
}
