//
//  BookmarkManager.swift
//  NewsReaderApp
//
//  Created by prema janoti on 09/12/24.
//

import SwiftUI
import CoreData

class BookmarkViewModel: ObservableObject {
    @Published var bookmarkedArticles: [BookmarkedArticle] = []

    private let viewContext = PersistenceController.shared.container.viewContext

    init() {
        fetchBookmarks()
    }

    // Fetch all bookmarked articles
    func fetchBookmarks() {
        let fetchRequest: NSFetchRequest<BookmarkedArticle> = BookmarkedArticle.fetchRequest()
        do {
            bookmarkedArticles = try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching bookmarks: \(error.localizedDescription)")
        }
    }

    // Save a bookmarked article
    func saveBookmark(article: Article) {
        let newBookmark = BookmarkedArticle(context: viewContext)
        newBookmark.id = article.id
        newBookmark.author = article.author
        newBookmark.title = article.title?.stripOutHtml()
        newBookmark.url = article.url
        newBookmark.content = article.content?.stripOutHtml()

        do {
            try viewContext.save()
            fetchBookmarks() // Reload the bookmarks
        } catch {
            print("Error saving bookmark: \(error.localizedDescription)")
        }
    }

    // Remove a bookmarked article
    func removeBookmark(article: Article) {
        let fetchRequest: NSFetchRequest<BookmarkedArticle> = BookmarkedArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", article.id)

        do {
            let bookmarksToDelete = try viewContext.fetch(fetchRequest)
            if let bookmarkToDelete = bookmarksToDelete.first {
                viewContext.delete(bookmarkToDelete)
                try viewContext.save()
                fetchBookmarks() // Reload the bookmarks
            }
        } catch {
            print("Error deleting bookmark: \(error.localizedDescription)")
        }
    }

    // Check if an article is bookmarked
    func isBookmarked(article: Article) -> Bool {
        return bookmarkedArticles.contains(where: { $0.id == article.id })
    }
}
