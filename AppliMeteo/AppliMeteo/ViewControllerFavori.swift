//
//  ViewController.swift
//  AppliMeteo
//
//  Created by tplocal on 22/02/2023.
//

import UIKit
import CoreData

class ViewControllerFavori: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource{

    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        let searchResult = searchController.searchResultsController as! SearchResultsTableViewController
        searchResult.search(searchText: searchText!, context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        searchController.dismiss(animated: false)
    }

    @IBOutlet weak var home: UINavigationItem!
    
    var locationHandler = LocationHandler()
    
    var listeCities : [CityEntity] = []
    
    override func viewDidLoad() {
        _ = loadCitiesFromJson(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        listeCities = findFavoriteCitiesFromCoreData(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        let searchResultsController = SearchResultsTableViewController(style: .plain)
        searchResultsController.definesPresentationContext = true
        let searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = self
        
        searchController.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if(listeCities.count == 0){
                return 1
            }
            else{
                return listeCities.count
            }
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cellule = tableView.dequeueReusableCell(withIdentifier: "maCellule",for: indexPath)
            if(listeCities.count == 0){
                cellule.textLabel?.text = "Pas de ville ajoutés"
            }
            else{
                cellule.textLabel?.text = listeCities[indexPath.row].name
            }
            return cellule
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            
            let VC = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            VC.ville.append(listeCities[indexPath.row])
            
            self.navigationController?.pushViewController(VC, animated: true)
        }
    
        func didDismissSearchController(_ searchController: UISearchController) {
            listeCities = findFavoriteCitiesFromCoreData(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            if let tableView = view.viewWithTag(1) as? UITableView {
                tableView.reloadData()
            }
        }
        
        func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            
            let detailVC = storyBoard.instantiateViewController(withIdentifier: "ViewControllerDetailsVille") as! ViewControllerDetailsVille
            
    //        tableView.deselectRow(at: indexPath, animated: true)
            
            detailVC.latitude = listeCities[indexPath.row].lat
            detailVC.longitude = listeCities[indexPath.row].lon
            detailVC.ville = listeCities[indexPath.row].name!
            
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    
}

class SearchResultsTableViewController: UITableViewController {
    
    var results: [CityEntity] = []
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func search(searchText: String, context: NSManagedObjectContext) {
        print("searching for \(searchText)")
        results = findCitiesFromCoreDataByName(name: searchText, context: context)
        // take the firsts 10 results
        results = Array(results.prefix(30))
        print(results)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let name = results[indexPath.row].name
        let country = results[indexPath.row].country
        let state = results[indexPath.row].state
        var str = name! + " " + country!
        if(state != "") {
            str += "/" + state!
        }
        cell.textLabel?.text = str
        
        let favoriteButton = UIButton(type: .custom)
        favoriteButton.tag = indexPath.row
        favoriteButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        favoriteButton.tintColor = .gray
        favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
        favoriteButton.isSelected = results[indexPath.row].favorite
        favoriteButton.tag = indexPath.row
        favoriteButton.addTarget(self, action: #selector(starButtonTapped(_ :)), for: .touchUpInside)
        cell.accessoryView = favoriteButton
        
        return cell
    }
    
    @objc func starButtonTapped(_ sender: UIButton) {
        let city = results[sender.tag]
        toggleFavorite(city: city, context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        sender.isSelected = city.favorite
    }
}
