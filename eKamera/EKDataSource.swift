//
//  File.swift
//  eKamera
//
//  Created by Кирилл Емельянов on 25.04.2021.
//
import os
import UIKit

class EKDataSource<T: Codable & Identifiable>: NSObject, UITableViewDataSource {
    private let pageSize = 20
    private var fetcher: (Int, @escaping (ApiResponse<T>) -> Void) -> Void
    private var items: [String:T] = [:]
    private var itemsOrder: [Int:[String]] = [:]
    private var _totalItems: Int  = 0
    private var pagesLoaded: [Int:Bool] = [:]
    private var pagesLoading: [Int:Bool] = [:]
    private var isEmpty = true
    private var templateName: String
    
    init(itemsFetcher: @escaping (Int, @escaping (ApiResponse<T>) -> Void) -> Void, cellTemplateName: String) {
        fetcher = itemsFetcher
        templateName = cellTemplateName
    }
    
    func clear() {
        isEmpty = true
        pagesLoaded = [:]
        items = [:]
        itemsOrder = [:]
        _totalItems = 0
    }
    
    func getItem(_ index: Int, tableView: UITableView) -> T? {
        var item: T?
        
        if isEmpty {
            fetchPage(page: 1, tableView: tableView)
            return item
        }
        
        let page = index / pageSize + 1
        let indexOnPage = index % pageSize
        if let loaded = self.pagesLoaded[page], loaded, let pageOrder = self.itemsOrder[page], indexOnPage < pageOrder.count {
            item = self.items[pageOrder[indexOnPage]]
        } else {
            fetchPage(page: page, tableView: tableView)
        }
        
        return item
    }
    
    func fetchPage(page: Int, tableView: UITableView) {
        if let loading = self.pagesLoading[page], loading {
            return
        }

        self.pagesLoading[page] = true
        fetcher(page) { [weak self] response in
            guard let self = self else {
                return
            }
            
            if self.getTotalItems(tableView: tableView) > 0 && self.getTotalItems(tableView: tableView) != response.count {
                // TODO: think about case, when new items appear on the first page and reorder all other pages
            }

            self.itemsOrder[page] = []
            var ordering: [String] = []
            for item in response.results {
                guard let itemId = item.id as? String else {
                    os_log("item id type is not String", log: OSLog.default, type: .error)
                    continue
                }
                self.items[itemId] = item
                ordering.append(itemId)
            }
            self.itemsOrder[page] = ordering
            
            self._totalItems = response.count
            self.pagesLoaded[page] = true
            self.pagesLoading[page] = false
            self.isEmpty = false
            
            DispatchQueue.main.async {
                tableView.reloadData()
            }
        }
    }
    
    func getTotalItems(tableView: UITableView) -> Int {
        if isEmpty {
            fetchPage(page: 1, tableView: tableView)
        }
        return _totalItems
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getTotalItems(tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpinnerCell", for: indexPath)

        if let item = getItem(indexPath.row, tableView: tableView) {
            guard let configurableCell = tableView.dequeueReusableCell(withIdentifier: templateName, for: indexPath) as? ConfigurableCell else {
                os_log("unexpected error, could not fetch data for cell", log: OSLog.default, type: .error)
                return cell
            }

            configurableCell.configure(item)
            
            return configurableCell
        }

        return cell
    }
}
