# NewsReaderApp

# Article Bookmarking in SwiftUI with Core Data

This project implements a simple news app where users can view articles, bookmark them, and see their bookmarked articles. The data is persisted using Core Data, allowing for efficient and scalable storage of bookmarked articles.

## Project Overview

- The app fetches articles from an API and allows users to view them in a list.
- Users can bookmark their favorite articles.
- Bookmarked articles are stored in Core Data, ensuring they persist across app launches.
- Bookmarked articles are displayed in a dedicated "Bookmarks" tab.

## Core Features

1. **Fetch Articles from an API**  
   The app fetches articles from a news API (NewsAPI) and displays them in a list.

2. **Bookmark Articles**  
   Users can bookmark articles. The app provides an interactive star button that allows users to toggle whether an article is bookmarked.

3. **Persist Bookmarks**  
   Bookmarked articles are stored using Core Data and will remain even after the app is closed or the device is restarted.

4. **View Bookmarked Articles**  
   A dedicated tab in the app shows the list of all the articles that the user has bookmarked.

---

## Getting Started

### Prerequisites

- **Xcode 12.0+** (for SwiftUI and Core Data support)
- An active internet connection to fetch articles from the API
- An Apple Developer account (optional for deploying on a device)

### Clone the Repository

To get started with the project, clone this repository:

```bash
git clone https://github.com/pjanoti/NewsReaderApp.git
```

### Open the Project

1. Open the `.xcodeproj` or `.xcworkspace` file in Xcode.
2. Build and run the app on a simulator or a physical device.

---

## Core Data Setup

### Core Data Model

1. **Create Core Data Model:**
   - In the `.xcdatamodeld` file, create an entity called `BookmarkedArticle`.
   - Add attributes that match the `Article` model you are using. These include:
     - `id: String`
     - `author: String`
     - `title: String`
     - `url: String`
     - `content: String`
  
2. **Generate NSManagedObject subclass:**
   - From the Core Data model, generate the `NSManagedObject` subclass for `BookmarkedArticle`.

### Core Data Stack

The Core Data stack is set up in the `PersistenceController` class, which is initialized in the app's entry point (`@main`).

```swift
class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "BookmarkModel")  // Match the name of your .xcdatamodeld file
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error.localizedDescription)")
            }
        }
    }
}
```

---

## Key ViewModel: `BookmarkViewModel`

The `BookmarkViewModel` is responsible for managing bookmarked articles using Core Data. Here's how it works:

1. **Fetching Bookmarked Articles:**

```swift
func fetchBookmarks() {
    let fetchRequest: NSFetchRequest<BookmarkedArticle> = BookmarkedArticle.fetchRequest()
    do {
        bookmarkedArticles = try viewContext.fetch(fetchRequest)
    } catch {
        print("Error fetching bookmarks: \(error.localizedDescription)")
    }
}
```

2. **Saving a Bookmark:**

```swift
func saveBookmark(article: Article) {
    let newBookmark = BookmarkedArticle(context: viewContext)
    newBookmark.id = article.id
    newBookmark.author = article.author
    newBookmark.title = article.title
    newBookmark.url = article.url
    newBookmark.content = article.content

    do {
        try viewContext.save()
        fetchBookmarks() // Reload the bookmarks
    } catch {
        print("Error saving bookmark: \(error.localizedDescription)")
    }
}
```

3. **Removing a Bookmark:**

```swift
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
```

---

## User Interface

### 1. **Article List View**

The ArticleListView displays a list of articles, and each article is displayed with its title, description, and a tag indicating if it is bookmarked.

Properties

* articles: The list of Article objects to display. This can include top headlines, all articles, or bookmarked articles.
* isDetailViewActive: A @Binding variable that controls whether the detail view is active or not when an article is selected.

Functionality
* Bookmark Tag: If an article is bookmarked, a "⭐ Bookmarked" tag is displayed next to the article title.
* Navigation: Tapping on an article navigates to the ArticleDetailView, where the user can view more details and bookmark the article.

```swift
struct ArticleListView: View {
    let articles: [Article]
    @Binding var isDetailViewActive: Bool
    @StateObject private var bookmarkViewModel = BookmarkViewModel() // Bookmark management

    var body: some View {
        if articles.isEmpty {
            Text("No bookmarked articles")
                .font(.system(size: 16, weight: .semibold, design: .default))
        } else {
            List(articles, id: \.id) { article in
                NavigationLink(destination: ArticleDetailView(article: article, isDetailViewActive: $isDetailViewActive)) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(article.title ?? "")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .lineLimit(2)
                            
                            // Display "⭐ Bookmarked" if article is bookmarked
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
```

### 2. **Article Detail View**

ArticleDetailView

The ArticleDetailView provides detailed information about a selected article. It includes a title, content, author name, and the option to bookmark or unbookmark the article.

Properties

* article: The Article object containing the details to display.
* isDetailViewActive: A @Binding variable that controls the state of the detail view navigation.

Functionality

* Bookmark Button: A button is displayed at the top of the article details that allows users to bookmark or remove the bookmark on an article. The button shows a star icon (⭐) to indicate the bookmark status. When tapped, the article is either saved to or removed from the bookmark list.
* Article Details: The article's title, author, content, and image (if available) are shown.

```swift
struct ArticleDetailView: View {
    let article: Article
    @StateObject private var bookmarkViewModel = BookmarkViewModel() // Manages the bookmark status
    @Binding var isDetailViewActive: Bool

    var body: some View {
        ScrollView {
            // Bookmark button at the top of the detail screen
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
```

---

## Run the App

1. Build and run the app on the simulator or a physical device.
2. Navigate to the "Top Headlines" or "All Articles" tab to view the articles.
3. Tap on the star icon to bookmark an article.
4. Switch to the "Bookmarks" tab to view your saved articles.

---

## Future Enhancements

1. **User Authentication**: Implement user authentication to sync bookmarks across multiple devices.
2. **Error Handling**: Improve error handling by showing user-friendly messages when there's an issue fetching or saving data.
3. **Article Sharing**: Add the ability to share articles with others.
4. **Sorting/Filtering**: Allow users to sort or filter bookmarked articles by date, title, etc.

---

## Contributing

1. Fork this repository.
2. Clone your fork to your local machine.
3. Create a feature branch (`git checkout -b feature-branch`).
4. Commit your changes (`git commit -am 'Add new feature'`).
5. Push to the branch (`git push origin feature-branch`).
6. Create a new pull request.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

### Thank you!
