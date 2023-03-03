//
// Created by Pierre Zachary on 24/02/2023.
//

import CoreData

class TemperatureForecast: NSManagedObject {
    @NSManaged var temp: Double
    @NSManaged var feels_like: Double
    @NSManaged var temp_min: Double
    @NSManaged var temp_max: Double
    @NSManaged var humidityLevel: Int32
    @NSManaged var windSpeed: Double
    @NSManaged var windDeg: Int32
    @NSManaged var weatherDescription: String
    @NSManaged var icon: String
    @NSManaged var dt_txt: String
    @NSManaged var dt: Int32
    @NSManaged var pressure: Int32
    @NSManaged var visibility: Int32
    @NSManaged var weatherData: WeatherData
}

class WeatherData: NSManagedObject {
    @NSManaged var sunrise: Int32
    @NSManaged var sunset: Int32
    @NSManaged var temperatureForecasts: Set<TemperatureForecast>
    @NSManaged var city: CityEntity
}

class CityEntity: NSManagedObject {
    @NSManaged var state: String
    @NSManaged var name: String
    @NSManaged var id: Int32
    @NSManaged var favorite: Bool
    @NSManaged var country: String
    @NSManaged var lon: Double
    @NSManaged var lat: Double
    @NSManaged var weatherData: Set<WeatherData>
}