//
//  WeatherData+CoreDataProperties.swift
//  AppliMeteo
//
//  Created by Pierre Zachary on 06/03/2023.
//
//

import Foundation
import CoreData


extension WeatherData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherData> {
        return NSFetchRequest<WeatherData>(entityName: "WeatherData")
    }

    @NSManaged public var sunrise: Int32
    @NSManaged public var sunset: Int32
    @NSManaged public var city: CityEntity?
    @NSManaged public var temperatureForecast: NSSet?
    @NSManaged public var temperatureForecastDaily: NSSet?

}

// MARK: Generated accessors for temperatureForecast
extension WeatherData {

    @objc(addTemperatureForecastObject:)
    @NSManaged public func addToTemperatureForecast(_ value: TemperatureForecast)

    @objc(removeTemperatureForecastObject:)
    @NSManaged public func removeFromTemperatureForecast(_ value: TemperatureForecast)

    @objc(addTemperatureForecast:)
    @NSManaged public func addToTemperatureForecast(_ values: NSSet)

    @objc(removeTemperatureForecast:)
    @NSManaged public func removeFromTemperatureForecast(_ values: NSSet)

}

// MARK: Generated accessors for temperatureForecastDaily
extension WeatherData {

    @objc(addTemperatureForecastDailyObject:)
    @NSManaged public func addToTemperatureForecastDaily(_ value: TemperatureForecastDaily)

    @objc(removeTemperatureForecastDailyObject:)
    @NSManaged public func removeFromTemperatureForecastDaily(_ value: TemperatureForecastDaily)

    @objc(addTemperatureForecastDaily:)
    @NSManaged public func addToTemperatureForecastDaily(_ values: NSSet)

    @objc(removeTemperatureForecastDaily:)
    @NSManaged public func removeFromTemperatureForecastDaily(_ values: NSSet)

}

extension WeatherData : Identifiable {

}
