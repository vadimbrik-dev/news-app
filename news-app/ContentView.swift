//
//  ContentView.swift
//  news-app
//
//  Created by Vadim Brik on 22.01.2021.
//

import SwiftUI
import WebKit

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

struct Article: Codable {
    let title: String?
    let description: String?
    let publishedAt: String?
    let content: String?
    let author: String?
    let source: ArticleSource
    let url: String?
    
    struct ArticleSource: Codable {
        let name: String?
    }
}

struct ArticlesResponse: Codable {
    let articles: [Article]
}

class FetchArticles: ObservableObject {
    let apiUrl = "https://newsapi.org/v2/top-headlines?country=us&apiKey=c884e0121bc24f1da0497794f1639a6d"
    
    @Published var articles = ArticlesResponse(articles: [])
    
    init() {
        if let url = URL(string: self.apiUrl) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                do {
                    if let articleResponse = data {
                        let decodedData = try JSONDecoder().decode(ArticlesResponse.self, from: articleResponse)
                        
                        DispatchQueue.main.async {
                            self.articles = decodedData
                        }
                    }
                } catch {
                    print("Error!")
                }
            }.resume()
        }
    }
}

struct ArticleVeiw: View {
    let article: Article
    
    var body: some View {
        WebView(url: URL(string: article.url!)!)
            .navigationBarTitle(article.title!)
            .ignoresSafeArea(.all)
    }
}

struct ContentView: View {
    @ObservedObject var fetchArticles = FetchArticles()
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            List(fetchArticles.articles.articles, id: \.title) { article in
                NavigationLink(destination: ArticleVeiw(article: article)) {
                    VStack(alignment: .leading) {
                        Text(article.title ?? "No title")
                            .font(.headline)
                            .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.15))
                        Text(article.description ?? "No description")
                            .font(.caption)
                            .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.25))
                            .padding(.vertical, 4.0)
                        HStack {
                            Text(article.source.name ?? "No source")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.35))
                            Spacer()
                            Text("\(ISO8601DateFormatter().date(from: article.publishedAt!)!, formatter: Self.dateFormatter)")
                                .font(.caption)
                                .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.35))
                        }
                    }
                    .padding(.all, 4.0)
                }
            }
            .navigationBarTitle("Latest news")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
