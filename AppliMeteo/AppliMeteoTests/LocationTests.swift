//
//  LocationTests.swift
//  AppliMeteoTests
//
//  Created by Pierre Zachary on 24/02/2023.
//

import XCTest
@testable import AppliMeteo

class LocationTests: XCTestCase {

    var locationHandler: LocationHandler!

    override func setUp() {
        super.setUp()
        locationHandler = LocationHandler()
    }

    override func tearDown() {
        locationHandler = nil
        super.tearDown()
    }

    func testGetUserLocation() {
        let location = locationHandler.getUserLocation()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if(location == nil){
            XCTFail("Location not found")
            return
        }
        print("Latitude: \(location!.coordinate.latitude), Longitude: \(location!.coordinate.longitude)")
        let expectation = XCTestExpectation(description: "Get user location meteo")
        let lon = location!.coordinate.longitude
        let lat = location!.coordinate.latitude
        fetchWeatherDataFromLonLat(context: context, lon: lon, lat: lat){ result in
            switch result {
            case .success(let weatherData):
                print("Weather data: \(weatherData)")
                let currentTemp: TemperatureForecast? = currentTemperature(weatherData: weatherData)
                if(currentTemp == nil){
                    XCTFail("Current temp not found")
                    return
                }
                print("City name: \(weatherData.city!.name)")
                print("Current temp time: \(currentTemp!.dt_txt)")
                print("Current picto: \(currentTemp!.icon)")
                print("Current temp: \(currentTemp!.temp)")
                print("sunrise on \(intToDate(unixTime: weatherData.sunrise))")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Error fetching weather data: \(error.localizedDescription)")
            }
            print("result: \(result)")
        }
        wait(for: [expectation], timeout: 10.0)
    }
}

