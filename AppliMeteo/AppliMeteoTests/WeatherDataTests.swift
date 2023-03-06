//
//  WeatherDataTests.swift
//  AppliMeteoTests
//
//  Created by Pierre Zachary on 24/02/2023.
//

import XCTest
@testable import AppliMeteo
import CoreData

final class WeatherDataTests: XCTestCase {

    func testFetchWeatherData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let cities = loadCitiesFromJson(context: context)
        if(cities == nil){
            XCTFail("Cities not found")
            return
        }
        let expectation = XCTestExpectation(description: "Fetch weather data")

        let id: Int32 = 6454159 // Orléans, FR
        let city = findCityFromCoreDataById(id: id as Int32, context: context)
        if(city == nil){
            XCTFail("City not found")
            return
        }
        print("City: \(city!.name)")
        if(city!.name != "Orléans"){
            XCTFail("City not found")
        }



        fetchWeatherData(context: context, for: city!) { result in
            switch result {
            case .success(let weatherData):
                print("Weather data: \(weatherData)")
                let currentTemp: TemperatureForecast? = currentTemperature(weatherData: weatherData)
                if(currentTemp == nil){
                    XCTFail("Current temp not found")
                    return
                }
                print("Current temp time: \(currentTemp!.dt_txt)")
                print("Current picto: \(currentTemp!.icon)")
                print("Current temp: \(currentTemp!.temp)")
                print("sunrise on \(intToDate(unixTime: weatherData.sunrise))")
                print("daily forecast for \(weatherData.temperatureForecastDaily!.count) days")
                let list = weatherData.sortedTemperatureForecastDaily
                for day in list {
                    print("Day: \(intToDate(unixTime: day.dt))")
                    print("Picto: \(day.weather_icon)")
                    print("Temp min: \(day.temp_min)")
                    print("Temp max: \(day.temp_max)")
                }
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Error fetching weather data: \(error.localizedDescription)")
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }



}
