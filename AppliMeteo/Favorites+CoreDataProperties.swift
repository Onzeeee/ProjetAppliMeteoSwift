//
//  Favorites+CoreDataProperties.swift
//  AppliMeteo
//
//  Created by Pierre Zachary on 06/03/2023.
//
//

import Foundation
import CoreData


extension Favorites {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorites> {
        return NSFetchRequest<Favorites>(entityName: "Favorites")
    }

    @NSManaged public var cities: NSOrderedSet?

}

// MARK: Generated accessors for city
extension Favorites {

    @objc(insertObject:inCityAtIndex:)
    @NSManaged public func insertIntoCity(_ value: CityEntity, at idx: Int)

    @objc(removeObjectFromCityAtIndex:)
    @NSManaged public func removeFromCity(at idx: Int)

    @objc(insertCity:atIndexes:)
    @NSManaged public func insertIntoCity(_ values: [CityEntity], at indexes: NSIndexSet)

    @objc(removeCityAtIndexes:)
    @NSManaged public func removeFromCity(at indexes: NSIndexSet)

    @objc(replaceObjectInCityAtIndex:withObject:)
    @NSManaged public func replaceCity(at idx: Int, with value: CityEntity)

    @objc(replaceCityAtIndexes:withCity:)
    @NSManaged public func replaceCity(at indexes: NSIndexSet, with values: [CityEntity])

    @objc(addCityObject:)
    @NSManaged public func addToCity(_ value: CityEntity)

    @objc(removeCityObject:)
    @NSManaged public func removeFromCity(_ value: CityEntity)

    @objc(addCity:)
    @NSManaged public func addToCity(_ values: NSOrderedSet)

    @objc(removeCity:)
    @NSManaged public func removeFromCity(_ values: NSOrderedSet)

}

extension Favorites : Identifiable {

}
