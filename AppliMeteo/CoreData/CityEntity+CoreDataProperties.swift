//
//  CityEntity+CoreDataProperties.swift
//  AppliMeteo
//
//  Created by Pierre Zachary on 06/03/2023.
//
//

import Foundation
import CoreData


extension CityEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CityEntity> {
        return NSFetchRequest<CityEntity>(entityName: "CityEntity")
    }

    @NSManaged public var country: String?
    @NSManaged public var favorite: Bool
    @NSManaged public var id: Int32
    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var name: String?
    @NSManaged public var state: String?
    @NSManaged public var weatherData: WeatherData?

}

extension CityEntity : Identifiable {

}
