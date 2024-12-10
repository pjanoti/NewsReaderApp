//
//  NewsViewModel.swift
//  NewsReaderApp
//
//  Created by prema janoti on 05/12/24.
//

import Foundation
import Combine
import SwiftUI

class ArticleViewModel: ObservableObject {
    @Published var allArticles = [Article]()
    @Published var topHeadlines = [Article]()
    @Published var error: String?
    private let apiKey = "07eb4eb39d39454db319c5c97739ba34"
    private let baseUrl = "https://newsapi.org/v2/"
    private let query = "q=Apple&sortBy=popularity"
    private var cancellables = Set<AnyCancellable>()
    
    @ObservedObject var bookmarkViewModel = BookmarkViewModel() // Observe BookmarkViewModel
    
    // Fetch all articles by category
    func fetchAllArticles(category: String) {
        let urlString = "\(baseUrl)\(category)?\(query)&apiKey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return
        }
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .handleEvents(receiveOutput: { data in
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw response: \(jsonString)")
                }
            })
            .decode(type: NewsResponse.self, decoder: JSONDecoder())
            .map { response in
                // Filter out articles where both title and description are empty
                return response.articles.filter { article in
                    !(article.title?.isEmpty ?? true) || !(article.description?.isEmpty ?? true)
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.error = error.localizedDescription
                }
            }, receiveValue: { articles in
                if category == "everything" {
                    self.allArticles = articles
                } else {
                    self.topHeadlines = articles
                }
            })
            .store(in: &cancellables)
    }
}
