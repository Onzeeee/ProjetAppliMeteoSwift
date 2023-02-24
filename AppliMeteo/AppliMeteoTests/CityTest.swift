//
//  CityTest.swift
//  AppliMeteoTests
//
//  Created by Pierre Zachary on 23/02/2023.
//

import XCTest
@testable import AppliMeteo
import CoreData

final class CityTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoadCitiesFromJson() {
        let bundle = Bundle(for: type(of: self))
        let urls = bundle.urls(forResourcesWithExtension: "json", subdirectory: nil)
        for url in urls ?? [] {
            print("File found: \(url.lastPathComponent)")
        }
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let cities = loadCitiesFromJson(context: context)
        print("Number of cities: \(cities.count)")
        // Assert that the list contains at least one city
        XCTAssertGreaterThan(cities.count, 0)

        let cities_coredata = fetchCitiesFromCoreData(context: context)
        print("Number of cities in coredata: \(cities_coredata.count)")
        // Assert that the list contains at least one city
        XCTAssertGreaterThan(cities_coredata.count, 0)
        // Assert the list from coredata has the same size as the list from json
        XCTAssertEqual(cities.count, cities_coredata.count)
    }

    func testFindCitiesFromCoreDataByName() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let cities = loadCitiesFromJson(context: context)
        // Find cities by name
        let searchQueries = ["Paris", "Pari", "paris", "paRis", "ARI"]
        for query in searchQueries {
            let foundCities = findCitiesFromCoreDataByName(name: query, context: context)
            print("Found \(foundCities.count) cities for query '\(query)'")
            print("Cities found: \(foundCities.map { $0.name })")
            XCTAssertTrue(foundCities.contains { $0.name == "Paris" },
                    "Failed to find Paris for query '\(query)'")
        }
    }

    func testFindCityPhotos(){
        let city = "Paris"
        let expectation = XCTestExpectation(description: "Fetch photos for city \(city)")
        findPhotos(query: city) { result in
            switch result {
            case .success(let photos):
                print("Photos for \(city): \(photos)")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Error fetching photos for city \(city): \(error.localizedDescription)")
            }
        }
        wait(for: [expectation], timeout: 30.0)
    }

    func testToggleFavorite(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let cities = loadCitiesFromJson(context: context)
        let city = cities[0]
        print("City: \(city.name)")
        print("Favorite: \(city.favorite)")
        let favorite = city.favorite
        toggleFavorite(city: city, context: context)
        print("Favorite: \(city.favorite)")
        XCTAssertEqual(city.favorite, !favorite)
        toggleFavorite(city: city, context: context)
        print("Favorite: \(city.favorite)")
        XCTAssertEqual(city.favorite, favorite)
    }
    
    func testFindFavoritesCities(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let cities = findFavoriteCitiesFromCoreData(context: context)
        print("Number of favorite cities: \(cities.count)")
        let num = cities.count
        let id: Int32 = 6454159 // Orléans, FR
        let city = findCityFromCoreDataById(id: id, context: context)
        let wasfav = city!.favorite
        toggleFavorite(city: city!, context: context)
        let cities2 = findFavoriteCitiesFromCoreData(context: context)
        print("Number of favorite cities: \(cities2.count)")
        if(wasfav){
            XCTAssertEqual(cities2.count, num-1)
        }
        else{
            XCTAssertEqual(cities2.count, num+1)
        }

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
