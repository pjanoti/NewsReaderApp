//
//  ArticleDetailView.swift
//  NewsReaderApp
//
//  Created by prema janoti on 06/12/24.
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @StateObject private var bookmarkViewModel = BookmarkViewModel()
    @Binding var isDetailViewActive: Bool

    var body: some View {
        ScrollView {
            // Bookmark button
            Button(action: {
                if bookmarkViewModel.isBookmarked(article: article) {
                    bookmarkViewModel.removeBookmark(article: article)
                } else {
                    bookmarkViewModel.saveBookmark(article: article)
                }
            }) {
                Image(systemName: bookmarkViewModel.isBookmarked(article: article) ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .imageScale(.large)
            }
            Spacer()
            VStack(alignment: .leading) {
                if let imageUrl = article.urlToImage, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 300)
                    } placeholder: {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(maxWidth: .infinity, maxHeight: 300)
                    }
                }

                Text(article.title ?? "No Title")
                    .font(.title)
                    .bold()
                    .padding(.top)

                Text("By \(article.author ?? "Unknown")")
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding(.bottom)

                Text("Published on: \(article.publishedAt ?? Date())")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.bottom)

                Divider()

                Text(article.content ?? "No Content")
                    .font(.body)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

