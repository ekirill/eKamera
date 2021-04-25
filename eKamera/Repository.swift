//
//  File.swift
//  eKamera
//
//  Created by Кирилл Емельянов on 25.04.2021.
//
import os
import Foundation

class Repository<T: Codable & Identifiable> {
    var fetcher: (Int, @escaping (ApiResponse<T>) -> Void) -> Void
    var items: [String:T] = [:]
    var itemsOrder: [String] = []
    var totalItems = 0
    var pagesLoaded = 0
    
    init(itemsFetcher: @escaping (Int, @escaping (ApiResponse<T>) -> Void) -> Void ) {
        fetcher = itemsFetcher
    }
    
    func isEmpty() -> Bool {
        return self.pagesLoaded == 0
    }
    
    func getItem(_ index: Int) -> T? {
        var item: T?

        if index < self.itemsOrder.count {
            let itemId = self.itemsOrder[index]
            item = self.items[itemId]
        }
        
        return item
    }
    
    func fetchFirst(_ completion: @escaping () -> Void) {
        if isEmpty() {
            fetchMore(completion)
        }
    }
    
    func fetchMore(_ completion: @escaping () -> Void) {
        let pageToLoad = self.pagesLoaded + 1
        
        fetcher(pageToLoad) { response in
            if self.totalItems > 0 && self.totalItems != response.count {
                // TODO: think about case, when new items appear on the first page and reorder all other pages
            }

            self.totalItems = response.count
            self.pagesLoaded = pageToLoad
            
            for item in response.results {
                guard let itemId = item.id as? String else {
                    os_log("item id type is not String", log: OSLog.default, type: .error)
                    continue
                }
                self.items[itemId] = item
                self.itemsOrder.append(itemId)
            }
            
            completion()
        }
    }
}
