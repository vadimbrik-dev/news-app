//
//  news_appApp.swift
//  news-app
//
//  Created by Vadim Brik on 22.01.2021.
//

import SwiftUI

@main
struct news_appApp: App {
    let endpoint: URL
    
    init() {
        guard let infoListPath = Bundle.main.path(forResource: "NewsAPI-Info", ofType: "plist") else {
            fatalError("Couldn't find file \"NewsAPI-Info.plist\".")
        }
                
        let plist = NSDictionary(contentsOfFile: infoListPath)

        guard let value = plist?.object(forKey: "API_KEY") as? String else {
            fatalError("Couldn't find key 'API_KEY' in 'TMDB-Info.plist'.")
        }
        
        guard let endpoint = URL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=\(value)") else {
            fatalError("Couldn't get API endpoint")
        }
        
        self.endpoint = endpoint
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(endpoint: self.endpoint)
        }
    }
}
