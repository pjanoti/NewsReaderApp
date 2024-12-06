//
//  ArticleDetailView.swift
//  NewsReaderApp
//
//  Created by prema janoti on 06/12/24.
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @Binding var isDetailViewActive: Bool

    var body: some View {
        ScrollView {
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
                Text(article.title ?? AppConstant.emptyString)
                    .font(.title)
                    .bold()
                    .padding(.top)
                
                Text("By \(article.author ?? "Unknown")")
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding(.bottom)
                
                Text("Published on:\n\(article.publishedAt ?? Date())")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.bottom)
                
                Divider()
                
                Text(article.content ?? AppConstant.emptyString)
                    .font(.system(size: 20))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isDetailViewActive = true
        }
        .onDisappear {
            isDetailViewActive = false
        }
    }
}

