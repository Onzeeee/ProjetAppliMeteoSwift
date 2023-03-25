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

    func testFetchWeatherData() throws {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let cities = loadCitiesFromJson(context: context)
        if(cities == nil){
            XCTFail("Cities not found")
            return
        }
        let expectation = XCTestExpectation(description: "Fetch weather data")

        let id: Int32 = 2989317 // Orléans, FR
        //let id: Int32 = 6455259 // Paris, FR
        let city = CityEntity.fromId(id: id, context: context)
        if(city == nil){
            XCTFail("City not found")
            return
        }
        print("City: \(city!.name)")

        Task{
            do{
                let weatherData = try await fetchWeatherData(context: context, for: city!, language: "fr")
                print("Weather data: \(weatherData)")
                if(weatherData == nil){
                    XCTFail("Weather data not found")
                    return
                }
                if(weatherData.city!.id != city!.id){
                    XCTFail("Weather data city is not the same as the city")
                    return
                }
                expectation.fulfill()
            }
            catch{
                XCTFail("Error: \(error)")
            }
        }


        wait(for: [expectation], timeout: 10.0)
        do{
            try context.save()
        }
        catch{
            XCTFail("Error saving context: \(error)")
        }
    }



}
