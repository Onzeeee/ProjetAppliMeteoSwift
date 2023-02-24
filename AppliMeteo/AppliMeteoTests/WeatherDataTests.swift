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
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Error fetching weather data: \(error.localizedDescription)")
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }



}
