//
//  NewsArticle.swift
//  NewsReaderApp
//
//  Created by prema janoti on 05/12/24.
//

import Foundation

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable, Identifiable {
    var id: String // To make each article identifiable
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    var publishedAt: Date?
    let content: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case author
        case url
        case publishedAt
        case content
        case urlToImage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let title = try container.decode(String.self, forKey: .title)
        self.title = (title == AppConstant.removed) ? nil : title
        let description = try container.decodeIfPresent(String.self, forKey: .description)
        self.description = (description == AppConstant.removed) ? nil : description
        let content = try container.decodeIfPresent(String.self, forKey: .content)
        self.content = (content == AppConstant.removed) ? nil : content
        self.author = try container.decodeIfPresent(String.self, forKey: .author)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.urlToImage = try container.decodeIfPresent(String.self, forKey: .urlToImage)
        // Use the URL as a unique identifier for each article
        self.id = self.url ?? UUID().uuidString
        
        // Custom decoding for 'publishedAt'
        if let publishedAtString = try container.decodeIfPresent(String.self, forKey: .publishedAt) {
            let formatter = ISO8601DateFormatter()
            if let date = formatter.date(from: publishedAtString) {
                self.publishedAt = date
            } else {
                self.publishedAt = nil
            }
        } else if let publishedAtTimestamp = try container.decodeIfPresent(Int.self, forKey: .publishedAt) {
            // Handle case where the time is provided as a Unix timestamp (Int)
            self.publishedAt = Date(timeIntervalSince1970: TimeInterval(publishedAtTimestamp))
        } else {
            self.publishedAt = nil
        }
    }
    
    init(bookmarkedArticle: BookmarkedArticle) {
        self.id = bookmarkedArticle.id ?? UUID().uuidString
        self.author = bookmarkedArticle.author
        self.title = bookmarkedArticle.title
        self.content = bookmarkedArticle.content
        self.url = bookmarkedArticle.url
        self.publishedAt = Date()
        self.urlToImage = AppConstant.emptyString
        self.description = bookmarkedArticle.content
    }
    
    static func getArticles(_ bookmarkedArticles: [BookmarkedArticle]) -> [Article] {
        var articles = [Article]()
        for bookmarkedArticle in bookmarkedArticles {
            articles.append(Article(bookmarkedArticle: bookmarkedArticle))
        }
        return articles
    }
    
}





