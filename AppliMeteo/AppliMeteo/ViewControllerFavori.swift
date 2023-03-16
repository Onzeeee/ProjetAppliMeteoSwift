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
    
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.showsSearchResultsController = true
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
        if(listeCities.count == 0){
            return false
        }
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
        searchController.dismiss(animated: true)
        let text = searchController.searchBar.text ?? ""
        if(text != ""){
            let searchHistory = createSearchHistory(searchString: text, date: Date.now, context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        }
        
    }

    @IBOutlet weak var home: UINavigationItem!

    var listeCities : [CityEntity] = []
    
    override func viewDidLoad() {

        listeCities = findFavoriteCitiesFromCoreData(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        let searchResultsController = SearchResultsTableViewController(style: .plain)
        searchResultsController.definesPresentationContext = true
        
        let searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = self
        searchResultsController.searchController = searchController

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
                cellule.accessoryType = .none
            }
            else{
                cellule.textLabel?.text = listeCities[indexPath.row].name
                cellule.accessoryType = .detailButton
            }
            return cellule
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print(indexPath)
            if(listeCities.count == 0){
                return
            }
            guard let previousViewController = navigationController?.viewControllers.reversed()[1] as? ViewControllerPourPageControl else {
                    print("no previous controller")
                    return
                }
            
            let targetCity = listeCities[indexPath.row]
            previousViewController.customPageViewController.initFavoris()
            guard let targetCityIndex = previousViewController.customPageViewController.listeCities.firstIndex(where: { $0.id == targetCity.id }) else{
                return
            }
                
            previousViewController.customPageViewController.currentIndex = targetCityIndex
            navigationController?.popViewController(animated: true)
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
            if(tableView.isEditing || listeCities.count == 0){
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
    
    var searchHistory: [SearchHistory] = []
    
    let leContexte = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var results: [CityEntity] = []
    
    var searchController: UISearchController? = nil
    
    
    func search(searchText: String, context: NSManagedObjectContext) {
        results = findCitiesFromCoreDataByName(name: searchText, context: context)
        // take the firsts 10 results
        results = Array(results.prefix(30))
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(results.count == 0 && searchController != nil && searchController?.searchBar.text == ""){
            searchController!.searchBar.text = searchHistory[indexPath.row].searchString
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(results.count == 0){
            if(searchController?.searchBar.text != ""){
                return 1
            }
            searchHistory = fetchHistoryOrdered(context: leContexte)
            return searchHistory.count
        }
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(results.count == 0){
            if(searchController?.searchBar.text != ""){
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.textLabel?.text = "Nothing found..."
                cell.accessoryView = nil
                return cell
            }
            print("display search history at index : "+String( indexPath.row) )
            let index = indexPath.row
            let historyString = searchHistory[index].searchString
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = historyString
            
            let arrowButton = UIButton(type: .custom)
            arrowButton.tag = index
            arrowButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            arrowButton.setImage(UIImage(systemName: "arrow.up.right"), for: .normal)
            cell.accessoryView = arrowButton
            return cell
        }
        else{
            let name = results[indexPath.row].name
            let country = results[indexPath.row].country
            let state = results[indexPath.row].state
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            var str = name! + " " + country!
            if(state != "") {
                str += "/" + state!
            }
            cell.textLabel?.text = str
            
            let favoriteButton = UIButton(type: .custom)
            favoriteButton.tag = indexPath.row
            favoriteButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
            favoriteButton.isSelected = results[indexPath.row].favorite
            favoriteButton.addTarget(self, action: #selector(starButtonTapped(_ :)), for: .touchUpInside)
            cell.accessoryView = favoriteButton
            
            return cell
        }
        
    }
    
    
    @objc func starButtonTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            let city = self.results[sender.tag]
            toggleFavorite(city: city, context: self.leContexte)
            sender.isSelected = city.favorite
        }
    }
}
