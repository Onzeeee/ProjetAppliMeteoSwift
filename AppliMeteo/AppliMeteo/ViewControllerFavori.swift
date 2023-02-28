//
//  ViewControllerFavori.swift
//  AppliMeteo
//
//  Created by tplocal on 25/02/2023.
//

import UIKit
import CoreData

class ViewControllerFavori: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UINavigationBarDelegate {
    
    @IBOutlet weak var navbar: UINavigationItem!
    @IBOutlet weak var tabelView: UITableView!
    
    let leContexte = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var listeCities : [CityEntity] = []

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
        
        let VC = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        VC.listeCities.append(listeCities[indexPath.row])
        
        self.navigationController?.pushViewController(VC, animated: true)
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
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        let searchResult = searchController.searchResultsController as! SearchResultsTableViewController
        searchResult.search(searchText: searchText!, context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        searchController.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabelView.dataSource = self
        let searchResultsController = SearchResultsTableViewController(style: .plain)
        searchResultsController.definesPresentationContext = true
        let searchController = UISearchController(searchResultsController: searchResultsController)
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        searchController.delegate = self
        listeCities = findFavoriteCitiesFromCoreData(context: leContexte)
        
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
        favoriteButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        favoriteButton.tintColor = .gray
        favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
        favoriteButton.isSelected = results[indexPath.row].favorite
        favoriteButton.addTarget(self, action: #selector(starButtonTapped(sender:)), for: .touchUpInside)
        cell.accessoryView = favoriteButton

        return cell
    }

    @objc func starButtonTapped(sender: UIButton) {
        let city = results[sender.tag]
        toggleFavorite(city: city, context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        sender.isSelected = city.favorite
    }
}

class FavoriteTableViewController: UITableViewController{

        var results: [CityEntity] = []

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return results.count
        }

        override func viewDidLoad() {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            results = findFavoriteCitiesFromCoreData(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        }

        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            var name = results[indexPath.row].name
            var country = results[indexPath.row].country
            var state = results[indexPath.row].state
            var str = name! + " " + country!
            if(state != "") {
                str += "/" + state!
            }
            cell.textLabel?.text = str

            let favoriteButton = UIButton(type: .custom)
            favoriteButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            favoriteButton.tintColor = .gray
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
            favoriteButton.isSelected = results[indexPath.row].favorite
            favoriteButton.addTarget(self, action: #selector(starButtonTapped(sender:)), for: .touchUpInside)
            cell.accessoryView = favoriteButton

            return cell
        }

        @objc func starButtonTapped(sender: UIButton) {
            let city = results[sender.tag]
            toggleFavorite(city: city, context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            sender.isSelected = city.favorite
        }
}
