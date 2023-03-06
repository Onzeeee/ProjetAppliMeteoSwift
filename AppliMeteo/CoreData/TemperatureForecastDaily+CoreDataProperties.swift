//
//  TemperatureForecastDaily+CoreDataProperties.swift
//  AppliMeteo
//
//  Created by Pierre Zachary on 06/03/2023.
//
//

import Foundation
import CoreData


extension TemperatureForecastDaily {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TemperatureForecastDaily> {
        return NSFetchRequest<TemperatureForecastDaily>(entityName: "TemperatureForecastDaily")
    }

    @NSManaged public var clouds: Int32
    @NSManaged public var dt: Int32
    @NSManaged public var feels_like_day: Double
    @NSManaged public var feels_like_eve: Double
    @NSManaged public var feels_like_morn: Double
    @NSManaged public var feels_like_night: Double
    @NSManaged public var gust: Double
    @NSManaged public var humidity: Int32
    @NSManaged public var pop: Double
    @NSManaged public var pressure: Int32
    @NSManaged public var rain: Double
    @NSManaged public var sunrise: Int32
    @NSManaged public var sunset: Int32
    @NSManaged public var temp_day: Double
    @NSManaged public var temp_eve: Double
    @NSManaged public var temp_max: Double
    @NSManaged public var temp_min: Double
    @NSManaged public var temp_morn: Double
    @NSManaged public var temp_night: Double
    @NSManaged public var weather_description: String?
    @NSManaged public var weather_icon: String?
    @NSManaged public var weather_icon_url: String?
    @NSManaged public var weather_id: Int32
    @NSManaged public var weather_main: String?
    @NSManaged public var wind_deg: Int32
    @NSManaged public var wind_speed: Double
    @NSManaged public var weatherData: WeatherData?

}

extension TemperatureForecastDaily : Identifiable {

}
