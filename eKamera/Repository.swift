//
//  File.swift
//  eKamera
//
//  Created by Кирилл Емельянов on 25.04.2021.
//
import os
import Foundation

class Repository<T: Codable & Identifiable> {
    let pageSize = 20
    var fetcher: (Int, @escaping (ApiResponse<T>) -> Void) -> Void
    var successFetch: () -> Void
    var items: [String:T] = [:]
    var itemsOrder: [String] = []
    var _totalItems: Int  = 0
    var totalItems: Int {
        get {
            if isEmpty {
                fetchPage(1)
            }
            return _totalItems
        }
        set (newVal) {
            _totalItems = newVal
        }
    }
    var pagesLoaded: [Int:Bool] = [:]
    var pagesLoading: [Int:Bool] = [:]
    var isEmpty = true
    
    init(itemsFetcher: @escaping (Int, @escaping (ApiResponse<T>) -> Void) -> Void, onSuccessFetch: @escaping () -> Void) {
        fetcher = itemsFetcher
        successFetch = onSuccessFetch
    }
    
    func getItem(_ index: Int) -> T? {
        var item: T?
        
        if isEmpty {
            fetchPage(1)
            return item
        }
        
        if index < self.itemsOrder.count {
            let itemId = self.itemsOrder[index]
            item = self.items[itemId]
        } else if index < self.totalItems {
            let pageToLoad = index / pageSize + 1
            fetchPage(pageToLoad)
        }
        
        return item
    }
    
    func fetchPage(_ page: Int) {
        if let loading = self.pagesLoading[page], loading {
            return
        }

        self.pagesLoading[page] = true
        fetcher(page) { [weak self] response in
            guard let self = self else {
                return
            }
            
            if self.totalItems > 0 && self.totalItems != response.count {
                // TODO: think about case, when new items appear on the first page and reorder all other pages
            }

            for item in response.results {
                guard let itemId = item.id as? String else {
                    os_log("item id type is not String", log: OSLog.default, type: .error)
                    continue
                }
                self.items[itemId] = item
                self.itemsOrder.append(itemId)
            }
            
            self.totalItems = response.count
            self.pagesLoaded[page] = true
            self.pagesLoading[page] = false
            self.isEmpty = false
            
            self.successFetch()
        }
    }
}
