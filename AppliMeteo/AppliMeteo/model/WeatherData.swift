//
//  WeatherData.swift
//  AppliMeteo
//
//  Created by Pierre Zachary on 24/02/2023.
//

import CoreData

func fetchWeatherDataFromLonLat(context: NSManagedObjectContext, lon: Double, lat: Double, completion: @escaping (Result<WeatherData, Error>) -> Void){
    let apiKey = ProcessInfo.processInfo.environment["OPENWEATHER_APIKEY"] ?? ""
    let urlstring = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&units=metric&appid=\(apiKey)"
    let url = URL(string: urlstring)!
    print("URL: \(url)")
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        print("data: \(data)")

        guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            completion(.failure(NSError(domain: "Invalid response from server", code: 0, userInfo: nil)))
            return
        }
        do {
            guard let weatherDataJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                completion(.failure(NSError(domain: "Invalid response from server", code: 0, userInfo: nil)))
                return
            }
            let city = weatherDataJson["city"] as! [String: Any]
            let name = city["name"] as! String
            let sunrise = city["sunrise"] as! Int32
            let sunset = city["sunset"] as! Int32
            let country = city["country"] as! String
            let list_forecast = weatherDataJson["list"] as! [[String: Any]]
            let weatherData = WeatherData(context: context)
            let cityId = city["id"] as! Int32
            weatherData.sunrise = sunrise
            weatherData.sunset = sunset
            weatherData.city = CityEntity.fromId(id: cityId, context: context)

            for forecast in list_forecast{
                let main = forecast["main"] as! [String: Any]
                let temp = main["temp"] as! Double
                let feels_like = main["feels_like"] as! Double
                let temp_min = main["temp_min"] as! Double
                let temp_max = main["temp_max"] as! Double
                let humidity = main["humidity"] as! Int32
                let wind = forecast["wind"] as! [String: Any]
                let speed = wind["speed"] as! Double
                let deg = wind["deg"] as! Int32
                let weather = forecast["weather"] as! [[String: Any]]
                let weather0 = weather[0] as! [String: Any]
                let description = weather0["description"] as! String
                let icon = weather0["icon"] as! String
//                let iconUrl = "https://openweathermap.org/img/wn/"+icon+"@4x.png"
                let dt_txt = forecast["dt_txt"] as! String
                let dt = forecast["dt"] as! Int32
                let pressure = main["pressure"] as! Int32
                let visibility = forecast["visibility"] as! Int32
                let temperatureforecast = TemperatureForecast(context: context)
                temperatureforecast.temp = temp
                temperatureforecast.feels_like = feels_like
                temperatureforecast.temp_min = temp_min
                temperatureforecast.temp_max = temp_max
                temperatureforecast.humidityLevel = humidity
                temperatureforecast.windSpeed = speed
                temperatureforecast.windDeg = deg
                temperatureforecast.weatherDescription = description
                temperatureforecast.icon = icon
                temperatureforecast.dt_txt = dt_txt
                temperatureforecast.dt = dt
                temperatureforecast.pressure = pressure
                temperatureforecast.visibility = visibility
                temperatureforecast.weatherData = weatherData
            }
            try context.save()
            completion(.success(weatherData))
        } catch {
            completion(.failure(error))
        }
    }
    task.resume()

}

func fetchWeatherData(context: NSManagedObjectContext, for cityEntity: CityEntity, completion: @escaping (Result<WeatherData, Error>) -> Void) {
    let apiKey = ProcessInfo.processInfo.environment["OPENWEATHER_APIKEY"] ?? ""
    let id = cityEntity.id
    let urlstring = "https://api.openweathermap.org/data/2.5/forecast?id=\(id)&units=metric&appid=\(apiKey)"
    let url = URL(string: urlstring)!
    print("URL: \(url)")
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            completion(.failure(NSError(domain: "Invalid response from server", code: 0, userInfo: nil)))
            return
        }
        do {
            guard let weatherDataJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                completion(.failure(NSError(domain: "Invalid response from server", code: 0, userInfo: nil)))
                return
            }
            let city = weatherDataJson["city"] as! [String: Any]
            let name = city["name"] as! String
            let sunrise = city["sunrise"] as! Int32
            let sunset = city["sunset"] as! Int32
            let country = city["country"] as! String
            let list_forecast = weatherDataJson["list"] as! [[String: Any]]
            let weatherData = WeatherData(context: context)
            weatherData.sunrise = sunrise
            weatherData.sunset = sunset
            weatherData.city = cityEntity

            for forecast in list_forecast{
                let main = forecast["main"] as! [String: Any]
                let temp = main["temp"] as! Double
                let feels_like = main["feels_like"] as! Double
                let temp_min = main["temp_min"] as! Double
                let temp_max = main["temp_max"] as! Double
                let humidity = main["humidity"] as! Int32
                let wind = forecast["wind"] as! [String: Any]
                let speed = wind["speed"] as! Double
                let deg = wind["deg"] as! Int32
                let weather = forecast["weather"] as! [[String: Any]]
                let weather0 = weather[0] as! [String: Any]
                let description = weather0["description"] as! String
                let icon = weather0["icon"] as! String
//                let iconUrl = "https://openweathermap.org/img/wn/"+icon+"@4x.png"
                let dt_txt = forecast["dt_txt"] as! String
                let dt = forecast["dt"] as! Int32
                let pressure = main["pressure"] as! Int32
                let visibility = forecast["visibility"] as! Int32
                let temperatureforecast = TemperatureForecast(context: context)
                temperatureforecast.temp = temp
                temperatureforecast.feels_like = feels_like
                temperatureforecast.temp_min = temp_min
                temperatureforecast.temp_max = temp_max
                temperatureforecast.humidityLevel = humidity
                temperatureforecast.windSpeed = speed
                temperatureforecast.windDeg = deg
                temperatureforecast.weatherDescription = description
                temperatureforecast.icon = icon
                temperatureforecast.dt_txt = dt_txt
                temperatureforecast.dt = dt
                temperatureforecast.pressure = pressure
                temperatureforecast.visibility = visibility
                temperatureforecast.weatherData = weatherData
            }
            try context.save()
            completion(.success(weatherData))
        } catch {
            completion(.failure(error))
        }
    }
    task.resume()
}

func intToDate(unixTime: Int32) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "GMT+1")
    dateFormatter.locale = NSLocale.current
    dateFormatter.dateFormat = "dd/MM HH:mm"
    let strDate = dateFormatter.string(from: date)
    return strDate
}

func currentTemperature(weatherData: WeatherData) -> TemperatureForecast? {
    if let temperatureForecast = weatherData.temperatureForecast{
        let list_forecast = temperatureForecast.allObjects as! [TemperatureForecast]
        // order by TemperatureForecast.dt
        let list_forecast_ordered = list_forecast.sorted(by: { (forecast1, forecast2) -> Bool in
            return forecast1.dt < forecast2.dt
        })
        // Get the first element
        let currentForecast = list_forecast_ordered[0]
        return currentForecast
    }

    return nil
}

extension WeatherData{
    var sunriseDate: String{
        return intToDate(unixTime: sunrise)
    }
    var sunsetDate: String{
        return intToDate(unixTime: sunset)
    }
    var currentTemperatureForecast: TemperatureForecast?{
        return currentTemperature(weatherData: self)
    }
}
