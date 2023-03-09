//
//  ViewController.swift
//  AppliMeteo
//
//  Created by tplocal on 22/02/2023.
//

import UIKit
import CoreData

class ViewControllerFavori: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func onEditButtonTapped(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
    }
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        let searchResult = searchController.searchResultsController as! SearchResultsTableViewController
        searchResult.search(searchText: searchText!, context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("row moved from \(sourceIndexPath.row) to \(destinationIndexPath.row)")
        moveFavorite(from: sourceIndexPath.row, to: destinationIndexPath.row, context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        listeCities = findFavoriteCitiesFromCoreData(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        // Reload the table view to reflect the changes
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("row deleted at \(indexPath.row)")
            toggleFavorite(city: listeCities[indexPath.row], context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            listeCities = findFavoriteCitiesFromCoreData(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            // Reload the table view to reflect the changes
            if(listeCities.count == 0){
                tableView.isEditing = false
                editButton.isEnabled = false
            }
            tableView.reloadData()

        }
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        searchController.dismiss(animated: false)
    }

    @IBOutlet weak var home: UINavigationItem!

    var listeCities : [CityEntity] = []
    
    override func viewDidLoad() {

        listeCities = findFavoriteCitiesFromCoreData(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        let searchResultsController = SearchResultsTableViewController(style: .plain)
        searchResultsController.definesPresentationContext = true
        let searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = self
        
        searchController.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        if(listeCities.count == 0){
            tableView.isEditing = false
            editButton.isEnabled = false
        }
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
            if(listeCities.count == 0){
                return
            }
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            
            let VC = storyBoard.instantiateViewController(withIdentifier: "ViewControllerPourPageControl") as! ViewControllerPourPageControl
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            VC.seuleVille = true
            
//            self.navigationController?.pushViewController(VC, animated: true)
        }
    
        func didDismissSearchController(_ searchController: UISearchController) {
            listeCities = findFavoriteCitiesFromCoreData(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            if let tableView = view.viewWithTag(1) as? UITableView {
                tableView.reloadData()
            }
            if(listeCities.count == 0){
                tableView.isEditing = false
                editButton.isEnabled = false
            }
            else{
                editButton.isEnabled = true
            }
        }
        
        func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
            if(tableView.isEditing){
                return
            }
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
    
    let leContexte = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var results: [CityEntity] = []
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func search(searchText: String, context: NSManagedObjectContext) {
        results = findCitiesFromCoreDataByName(name: searchText, context: context)
        // take the firsts 10 results
        results = Array(results.prefix(30))
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
        DispatchQueue.main.async {
            let city = self.results[sender.tag]
            toggleFavorite(city: city, context: self.leContexte)
            sender.isSelected = city.favorite
        }
    }
}
