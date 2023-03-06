//
// Created by Pierre Zachary on 23/02/2023.
//

import CoreData

func loadCitiesFromJson(context: NSManagedObjectContext) -> [CityEntity] {
    do {
        let fetchRequest: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        let existingCities: [CityEntity] = try context.fetch(fetchRequest)
        if !existingCities.isEmpty {
            // Cities already exist in the store, no need to load from JSON
            return existingCities;
            // Delete all cities
//            for city in existingCities {
//                context.delete(city)
//            }
//            try context.save()
        }
    } catch let error {
        fatalError("Error fetching cities from Core Data: \(error)")
    }

    var cities = [CityEntity]()

    guard let path = Bundle.main.path(forResource: "city.list", ofType: "json") else {
        fatalError("city.list.json not found")
    }

    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let citiesData = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]

        for cityData in citiesData {
            let id = cityData["id"] as! Int32
            let name = cityData["name"] as! String
            let coord = cityData["coord"] as! [String: Any]
            let lat = coord["lat"] as! Double
            let lon = coord["lon"] as! Double
            let country_code = cityData["country"] as! String
            let state = cityData["state"] as! String
            let city = CityEntity(context: context)
            city.id = id
            city.name = name
            city.lat = lat
            city.lon = lon
            city.country = country_code
            city.state = state
            city.favorite = false
            cities.append(city)

        }
    } catch let error {
        fatalError("Error loading cities data: \(error)")
    }

    do {
        try context.save()
    } catch let error {
        fatalError("Error saving cities data: \(error)")
    }

    return cities
}

@available(*, deprecated, message: "Use loadCitiesFromJson() instead")
func fetchCitiesFromCoreData(context: NSManagedObjectContext) -> [CityEntity] {
    let fetchRequest = CityEntity.fetchRequest() as NSFetchRequest<CityEntity>
    do {
        let cities = try context.fetch(fetchRequest)
        return cities
    } catch let error {
        fatalError("Error fetching cities from Core Data: \(error)")
    }
}

func findCityFromCoreDataById(id: Int32, context: NSManagedObjectContext) -> CityEntity? {
    let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
    let predicate = NSPredicate(format: "id == %d", id)
    request.predicate = predicate
    do {
        let cities = try context.fetch(request)
        if cities.count > 0 {
            return cities[0]
        }

    } catch let error {
        fatalError("Error fetching cities: \(error)")
    }
    return nil
}

func findCitiesFromCoreDataByName(name: String, context: NSManagedObjectContext) -> [CityEntity] {
    let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
    let pattern = "\\b\(name)"
    // predicate to match the pattern at the beginning of the string
    let predicate = NSPredicate(format: "name BEGINSWITH[cd] %@", name)
    request.predicate = predicate
    do {
        var cities = try context.fetch(request)
        if (cities.count < 30) {
            cities = cities.sorted { (city1, city2) -> Bool in
                guard let name1 = city1.name as String?, let name2 = city2.name as String? else {
                    return false
                }
                let matchPercentage1 = name1.matchPercentage(with: name)
                let matchPercentage2 = name2.matchPercentage(with: name)
                return matchPercentage1 > matchPercentage2
            }
        }
        return cities

    } catch let error {
        fatalError("Error fetching cities: \(error)")
    }
}


extension String {
    func matchPercentage(with query: String) -> Double {
        let count = self.count
        let queryCount = query.count
        if count == 0 || queryCount == 0 {
            return 0.0
        }
        let distance = self.distance(to: query)
        let matchPercentage = (count - distance) * 100 / count
        return Double(matchPercentage)
    }

    private func distance(to string: String) -> Int {
        let s = self.lowercased()
        let t = string.lowercased()
        var d = Array(repeating: Array(repeating: 0, count: t.count + 1), count: s.count + 1)

        for i in 0...s.count {
            d[i][0] = i
        }
        for j in 0...t.count {
            d[0][j] = j
        }

        for i in 1...s.count {
            for j in 1...t.count {
                if s[s.index(s.startIndex, offsetBy: i-1)] == t[t.index(t.startIndex, offsetBy: j-1)] {
                    d[i][j] = d[i-1][j-1]
                } else {
                    let deletion = d[i-1][j] + 1
                    let insertion = d[i][j-1] + 1
                    let substitution = d[i-1][j-1] + 1
                    d[i][j] = Swift.min(deletion, insertion, substitution)
                }
            }
        }

        return d[s.count][t.count]
    }
}

func toggleFavorite(city: CityEntity, context: NSManagedObjectContext) {
    city.favorite = !city.favorite
    if(city.favorite) {
        favoriteCities.append(city)
    } else {
        favoriteCities.removeAll(where: { $0.id == city.id })
    }
    do {
        try context.save()
    } catch let error {
        fatalError("Error saving city favorite: \(error)")
    }
}

var favoriteCities: [CityEntity] = []

func findFavoriteCitiesFromCoreData(context: NSManagedObjectContext) -> [CityEntity] {
    if(favoriteCities.count > 0) {
        return favoriteCities
    }
    print("fetching favorite cities from core data")
    let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
    let predicate = NSPredicate(format: "favorite == true")
    request.predicate = predicate
    do {
        let cities = try context.fetch(request)
        favoriteCities = cities
        return cities
    } catch let error {
        fatalError("Error fetching cities: \(error)")
    }
}


func findPhotos(query: String, completion: @escaping (Result<[String], Error>) -> Void) {
    let PIXABAY_APIKEY = ProcessInfo.processInfo.environment["PIXABAY_APIKEY"] ?? ""
    if(PIXABAY_APIKEY.isEmpty) {
        fatalError("PIXABAY_APIKEY not found")
    }
    let query_photo = query
    let encodedString = query_photo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!.replacingOccurrences(of: "%20", with: "+")
    print(encodedString)
    let url = URL(string: "https://pixabay.com/api/?key=\(PIXABAY_APIKEY)&q=\(encodedString)&image_type=photo")
    if(url == nil){
        // completion error with message : pixabay url is nil
        fatalError("PIXABAY Url is nil")
    }
    print("url: \(url!)")
    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        guard let data = data else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
            return
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            let hits = json["hits"] as! [[String: Any]]
            let photos = hits.map { (hit) -> String in
                return hit["webformatURL"] as! String
            }
            completion(.success(photos))
        } catch let error {
            completion(.failure(error))
        }
    }
    task.resume()
}

extension CityEntity{
    static func == (lhs: CityEntity, rhs: CityEntity) -> Bool {
        return lhs.id == rhs.id
    }

    static func fromId(id: Int32, context: NSManagedObjectContext) -> CityEntity? {
        return findCityFromCoreDataById(id: id, context: context)
    }

    static func fromName(name: String, context: NSManagedObjectContext) -> [CityEntity] {
        return findCitiesFromCoreDataByName(name: name, context: context)
    }

    static func favoriteCities(context: NSManagedObjectContext) -> [CityEntity] {
        return findFavoriteCitiesFromCoreData(context: context)
    }

    static func allCities(context: NSManagedObjectContext) -> [CityEntity] {
        return loadCitiesFromJson(context: context)
    }
}
