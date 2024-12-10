//
//  ArticleListView.swift
//  NewsReaderApp
//
//  Created by prema janoti on 10/12/24.
//

import SwiftUI

struct ArticleListView: View {
    let articles: [Article]
    @Binding var isDetailViewActive: Bool
    @StateObject private var bookmarkViewModel = BookmarkViewModel() // Assuming a BookmarkViewModel to manage bookmarks

    var body: some View {
        if articles.isEmpty {
            Text("No bookmarked articles")
                .font(.system(size: 16, weight: .semibold, design: .default))
        } else {
            List(articles, id: \.id) { article in
                NavigationLink(destination: ArticleDetailView(article: article, isDetailViewActive: $isDetailViewActive)) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(article.title ?? AppConstant.emptyString)
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .lineLimit(2)
                            
                            // Show a tag for bookmarked articles
                            if bookmarkViewModel.isBookmarked(article: article) {
                                Text("⭐ Bookmarked")
                                    .font(.system(size: 12))
                                    .foregroundColor(.yellow)
                                    .padding(5)
                                    .background(Color.yellow.opacity(0.2))
                                    .cornerRadius(5)
                            }
                        }
                        
                        Text(article.description ?? "")
                            .font(.system(size: 12))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .listStyle(.inset)
        }
    }
}
