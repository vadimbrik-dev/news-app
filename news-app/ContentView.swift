//
//  ContentView.swift
//  news-app
//
//  Created by Vadim Brik on 22.01.2021.
//

import SwiftUI
import WebKit
import SafariServices

struct WebView: UIViewRepresentable {
    typealias UIViewType = WKWebView

    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()

        webView.load(URLRequest(url: self.url))

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {

    }
}

struct SafariView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SFSafariViewController
    
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        
        configuration.entersReaderIfAvailable = true
        
        return SFSafariViewController(url: url, configuration: configuration)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
}

struct Article: Codable, Identifiable {
    var id = UUID()
    let title: String
    let url: URL
    let description: String?
    let publishedAt: String?
    let source: Source

    enum CodingKeys: String, CodingKey {
        case title, url, description, publishedAt, source
    }
    
    struct Source: Codable {
        let name: String?
    }
}

struct ArticlesResponse: Codable {
    let articles: [Article]?
    let status: Status
    
    enum Status: String, Codable {
        case ok, error
    }
}

class APIRequest<Struct: Codable>: ObservableObject {
    @Published var response: Struct?
    @Published var error: String?
    
    init(_ endpoint: URL) {
        URLSession.shared.dataTask(with: endpoint) { data, response, error in
            if let error = error {
                self.setError(message: error.localizedDescription)
            } else if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(Struct.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.response = decodedData
                    }
                } catch {
                    self.setError(message: "Data parsing error")
                }
            }
        }.resume()
    }
    
    func setError(message: String) {
        DispatchQueue.main.async {
            self.error = message
        }
    }
}

struct ArticleView: View {
    let article: Article
    
    var body: some View {
        #if targetEnvironment(macCatalyst)
            SafariView(url: article.url)
                .ignoresSafeArea(SafeAreaRegions.all, edges: Edge.Set(Edge.bottom))
                .navigationBarTitle(article.title)
                .navigationBarTitleDisplayMode(.inline)
        #else
            WebView(url: article.url)
                .ignoresSafeArea()
                .navigationBarTitle(article.title)
                .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct ArticleItemView: View {
    let article: Article
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(self.article.title)
                .font(.headline)
            Text(article.description ?? "No description")
                .font(.caption)
                .padding(.vertical, 1.0)
            HStack {
                Text(article.source.name ?? "Unknown source")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(Color.gray)
                Spacer()
                Text("\(ISO8601DateFormatter().date(from: article.publishedAt!)!, formatter: Self.dateFormatter)")
                    .font(.footnote)
                    .foregroundColor(Color.gray)
            }
            .padding(.top, 4.0)
        }
        .padding(.vertical)
    }
}

struct NewsFeedView: View {
    let articles: [Article]
    
    var body: some View {
        NavigationView {
            List(self.articles) { article in
                NavigationLink(destination: ArticleView(article: article)) {
                    ArticleItemView(article: article)
                }
            }
            .navigationBarTitle("Latest news")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

struct NewsFeedErrorView: View {
    let message: String
    
    var body: some View {
        VStack {
            Image("panic")
                .padding(.all)
            Text("Don't panic and try again later")
                .font(.headline)
                .padding(.vertical, 4.0)
            Text(self.message)
                .font(.caption)
                .foregroundColor(Color.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .frame(width: 256.0)
        }
    }
}

struct NewsFeedLoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .padding(.all)
            Text("Loading articles".uppercased())
                .font(.caption)
                .foregroundColor(Color.gray)
        }
    }
}

typealias ArticlesRequest = APIRequest<ArticlesResponse>

struct ContentView: View {
    @ObservedObject var articlesRequest: ArticlesRequest
    
    init(endpoint: URL) {
        self.articlesRequest = ArticlesRequest(endpoint)
    }
    
    var body: some View {
        if let response = articlesRequest.response {
            if response.status == ArticlesResponse.Status.ok {
                NewsFeedView(articles: response.articles!)
            } else {
                NewsFeedErrorView(message: "Request was successful, but data has not received.")
            }
        } else if let error = articlesRequest.error {
            NewsFeedErrorView(message: error)
        } else {
            NewsFeedLoadingView()
        }
    }
}
