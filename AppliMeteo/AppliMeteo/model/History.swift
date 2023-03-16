//
//  History.swift
//  AppliMeteo
//
//  Created by Pierre Zachary on 16/03/2023.
//

import Foundation
import CoreData


func fetchHistoryOrdered(context: NSManagedObjectContext) -> [SearchHistory] {
    let request: NSFetchRequest<SearchHistory> = SearchHistory.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    request.fetchLimit = 20 // the 20 latest searchs
    do {
        let searchHistory = try context.fetch(request)
        return searchHistory
    } catch {
        print("Error fetching search history: \(error)")
        return []
    }
}

func createSearchHistory(searchString: String, date: Date, context: NSManagedObjectContext) -> SearchHistory? {
    let request: NSFetchRequest<SearchHistory> = SearchHistory.fetchRequest()
        request.predicate = NSPredicate(format: "searchString = %@", searchString)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            var entity: SearchHistory? = nil
            let searchHistory = try context.fetch(request)
            
            if let existingHistory = searchHistory.first {
                existingHistory.date = date
                entity = existingHistory
            } else {
                let newHistory = SearchHistory(context: context)
                newHistory.searchString = searchString
                newHistory.date = date
                
                // Remove oldest search history entity if there are more than 20 entities
                if let searchHistories = try? context.fetch(SearchHistory.fetchRequest()) as? [SearchHistory], searchHistories.count >= 20 {
                    let oldestHistory = searchHistories.last!
                    context.delete(oldestHistory)
                }
                entity = newHistory
            }
            
            try context.save()
            return entity
        } catch {
            print("Error creating/updating search history: \(error)")
        }
    return nil
}
