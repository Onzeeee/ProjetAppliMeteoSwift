//
//  TemperatureForecast+CoreDataProperties.swift
//  AppliMeteo
//
//  Created by Pierre Zachary on 06/03/2023.
//
//

import Foundation
import CoreData


extension TemperatureForecast {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TemperatureForecast> {
        return NSFetchRequest<TemperatureForecast>(entityName: "TemperatureForecast")
    }

    @NSManaged public var dt: Int32
    @NSManaged public var dt_txt: String?
    @NSManaged public var feels_like: Double
    @NSManaged public var humidityLevel: Int32
    @NSManaged public var icon: String?
    @NSManaged public var pressure: Int32
    @NSManaged public var temp: Double
    @NSManaged public var temp_max: Double
    @NSManaged public var temp_min: Double
    @NSManaged public var visibility: Int32
    @NSManaged public var weatherDescription: String?
    @NSManaged public var windDeg: Int32
    @NSManaged public var windSpeed: Double
    @NSManaged public var weatherData: WeatherData?

}

extension TemperatureForecast : Identifiable {

}
