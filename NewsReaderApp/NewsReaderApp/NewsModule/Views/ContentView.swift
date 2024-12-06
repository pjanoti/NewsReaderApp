//
//  ContentView.swift
//  NewsReaderApp
//
//  Created by prema janoti on 05/12/24.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = ArticleViewModel()
    @State private var isDetailViewActive = false
    
    var body: some View {
        TabView {
            
            // Tab for Top Headlines
            NavigationView {
                ArticleListView(articles: viewModel.topHeadlines, isDetailViewActive: $isDetailViewActive)
                    .onAppear {
                        viewModel.fetchAllArticles(category: "top-headlines")
                    }
                    .navigationTitle("Top Headlines")
            }
            .tabItem {
                Label("Top Headlines", systemImage: "star.fill")
            }
            
            // Tab for All Articles
            NavigationView {
                ArticleListView(articles: viewModel.allArticles, isDetailViewActive: $isDetailViewActive)
                    .onAppear {
                        viewModel.fetchAllArticles(category: "everything")
                    }
                    .navigationTitle("All Articles")
            }
            .tabItem {
                Label("All Articles", systemImage: "list.dash")
            }
            
        }
    }
}
    

struct ArticleListView: View {
    let articles: [Article]
    @Binding var isDetailViewActive: Bool

    var body: some View {
        List(articles, id: \.id) { article in
            NavigationLink(destination: ArticleDetailView(article: article, isDetailViewActive: $isDetailViewActive)) {
                VStack(alignment: .leading) {
                    Text(article.title ?? "")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .lineLimit(4)
                    Text(article.description ?? "")
                        .font(.system(size: 12))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
            }
        }.listStyle(.inset)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


