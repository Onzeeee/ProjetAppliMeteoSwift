//
//  WeatherData.swift
//  AppliMeteo
//
//  Created by Pierre Zachary on 24/02/2023.
//

import CoreData

func performRequest(url: URL) async throws -> [String: Any] {
    let (data, response) = try await URLSession.shared.data(from: url)
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: nil)
    }
    guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: nil)
    }
    return jsonObject
}


func fetchWeatherDataFromLonLat(context: NSManagedObjectContext, lon: Double, lat: Double) async throws -> WeatherData{

    let apiKey = ProcessInfo.processInfo.environment["OPENWEATHER_APIKEY"] ?? ""
    let urlstring = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&units=metric&appid=\(apiKey)"
    let url = URL(string: urlstring)!
    let weatherDataJson = try await performRequest(url: url)
    let city = weatherDataJson["city"] as! [String: Any]
    let cityId = city["id"] as! Int32
    let urlstring_dailyforecast = "https://api.openweathermap.org/data/2.5/forecast/daily?id=\(cityId)&units=metric&appid=\(apiKey)&cnt=16"
    let url_daily = URL(string: urlstring_dailyforecast)!
    let weatherDataJson_daily = try await performRequest(url: url_daily)
    var weatherData: WeatherData?
    await context.perform{
        print("received weather data for city: \(city["name"] as! String)")
        let list_forecast = weatherDataJson["list"] as! [[String: Any]]
        weatherData = WeatherData(context: context)
        guard let weatherData = weatherData else {
            fatalError("weatherData is nil")
        }
        let CityEntityFromCoreData = CityEntity.fromId(id: cityId, context: context)
        if(CityEntityFromCoreData == nil) {
            print("City not found in core data, creating it... \(cityId as Int32)")
            let NewCityEntity = CityEntity(context: context)
            NewCityEntity.id = cityId
            NewCityEntity.name = city["name"] as? String
            NewCityEntity.country = city["country"] as? String
            weatherData.city = NewCityEntity
        }
        else {
            weatherData.city = CityEntityFromCoreData!
        }
        guard weatherData.city != nil else {
            fatalError("weatherData.city is nil")
        }
        for forecast in list_forecast{
            let main = forecast["main"] as! [String: Any]
            let wind = forecast["wind"] as! [String: Any]
            let weather = forecast["weather"] as! [[String: Any]]
            let weather0 = weather[0]
            let temperatureforecast = TemperatureForecast(context: context)
            temperatureforecast.temp = main["temp"] as! Double
            temperatureforecast.feels_like = main["feels_like"] as! Double
            temperatureforecast.temp_min = main["temp_min"] as! Double
            temperatureforecast.temp_max = main["temp_max"] as! Double
            temperatureforecast.humidityLevel = main["humidity"] as! Int32
            temperatureforecast.windSpeed = wind["speed"] as! Double
            temperatureforecast.windDeg = wind["deg"] as! Int32
            temperatureforecast.weatherDescription = weather0["description"] as? String
            temperatureforecast.icon = weather0["icon"] as? String
            temperatureforecast.dt_txt = forecast["dt_txt"] as? String
            temperatureforecast.dt = forecast["dt"] as! Int32
            temperatureforecast.pressure = main["pressure"] as! Int32
            temperatureforecast.visibility = forecast["visibility"] as! Int32
            temperatureforecast.weatherData = weatherData
        }

        let list = weatherDataJson_daily["list"] as! [[String: Any]]
        print("received daily weather data for city: \(city["name"] as! String)")
        for dailyForecastJson in list {
            let temp = dailyForecastJson["temp"] as! [String: Any]
            let feels_like = dailyForecastJson["feels_like"] as! [String: Any]
            let weather = dailyForecastJson["weather"] as! [[String: Any]]
            let weather0 = weather[0]
            let dailyForecast = TemperatureForecastDaily(context: context)
            dailyForecast.dt = dailyForecastJson["dt"] as! Int32
            dailyForecast.sunrise = dailyForecastJson["sunrise"] as! Int32
            dailyForecast.sunset = dailyForecastJson["sunset"] as! Int32
            dailyForecast.pressure = dailyForecastJson["pressure"] as! Int32
            dailyForecast.humidity = dailyForecastJson["humidity"] as! Int32
            dailyForecast.wind_speed = dailyForecastJson["speed"] as! Double
            dailyForecast.wind_deg = dailyForecastJson["deg"] as! Int32
            dailyForecast.clouds = dailyForecastJson["clouds"] as! Int32
            dailyForecast.pop = dailyForecastJson["pop"] as? Double ?? 0.0
            dailyForecast.rain = dailyForecastJson["rain"] as? Double ?? 0.0
            dailyForecast.gust = dailyForecastJson["gust"] as? Double ?? 0.0
            dailyForecast.temp_day = temp["day"] as! Double
            dailyForecast.temp_min = temp["min"] as! Double
            dailyForecast.temp_max = temp["max"] as! Double
            dailyForecast.temp_night = temp["night"] as! Double
            dailyForecast.temp_eve = temp["eve"] as! Double
            dailyForecast.temp_morn = temp["morn"] as! Double
            dailyForecast.feels_like_day = feels_like["day"] as! Double
            dailyForecast.feels_like_night = feels_like["night"] as! Double
            dailyForecast.feels_like_eve = feels_like["eve"] as! Double
            dailyForecast.feels_like_morn = feels_like["morn"] as! Double
            dailyForecast.weather_description = weather0["description"] as? String
            dailyForecast.weather_icon = weather0["icon"] as? String
            dailyForecast.weather_main = weather0["main"] as? String
            dailyForecast.weather_id = Int32(weather0["id"] as? Int ?? 0)
            dailyForecast.weatherData = weatherData
        }
        do{
            try context.save()
        } catch let error {
            fatalError("Error saving context: \(error)")
        }
    }

    guard weatherData != nil else {
        fatalError("weatherData is nil")
    }
    return weatherData!
}

func fetchWeatherData(context: NSManagedObjectContext, for cityEntity: CityEntity) async throws -> WeatherData {
    print("fetchWeatherData for city \(String(describing: cityEntity.name)) with lon \(cityEntity.lon) and lat \(cityEntity.lat)")
    let weatherData = try await fetchWeatherDataFromLonLat(context: context, lon: cityEntity.lon, lat: cityEntity.lat)
    print("fetchWeatherData for city \(String(describing: cityEntity.name)) with id \(cityEntity.id) Done !")
    return weatherData
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
    var currentTemperatureForecast: TemperatureForecast?{
        return currentTemperature(weatherData: self)
    }

    var sortedTemperatureForecast: [TemperatureForecast]{
        if let temperatureForecast = self.temperatureForecast{
            let list_forecast = temperatureForecast.allObjects as! [TemperatureForecast]
            // order by TemperatureForecast.dt
            let list_forecast_ordered = list_forecast.sorted(by: { (forecast1, forecast2) -> Bool in
                return forecast1.dt < forecast2.dt
            })
            return list_forecast_ordered
        }
        return []
    }

    var sortedTemperatureForecastDaily: [TemperatureForecastDaily]{
        if let temperatureForecastDaily = self.temperatureForecastDaily{
            let list_forecast = temperatureForecastDaily.allObjects as! [TemperatureForecastDaily]
            // order by TemperatureForecast.dt
            let list_forecast_ordered = list_forecast.sorted(by: { (forecast1, forecast2) -> Bool in
                return forecast1.dt < forecast2.dt
            })
            return list_forecast_ordered
        }
        return []
    }
}
