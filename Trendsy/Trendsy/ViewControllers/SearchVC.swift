//
//  SearchVC.swift
//  Trendsy
//
//  Created by Michelle Ho on 12/4/18.
//  Copyright © 2018 Michelle Ho. All rights reserved.
//
//
//  SearchVC.swift
//  Trendsy
//
//  Created by Michelle Ho on 12/4/18.
//  Copyright © 2018 Michelle Ho. All rights reserved.
//
import UIKit

class SearchVC: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    var appData = AppData.shared
    var isBlue = false
    
    var searchedElement = [String]()
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.scopeButtonTitles = ["Location", "Categories"]
        appData.selectedScope = 0
        
        appData.inCat = false
        appData.inSearch = true
    }
    
    // Functions make the keyboard slide away when user decides to scroll
    // through  the options.
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }

}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isSearching) {
            return searchedElement.count
        } else if (appData.selectedScope == 0) {
            return appData.locations.count
        } else {
            return appData.categoriesToSearch.count
        }
    }
    
    // Function Populates rows with data depending on user selections/searches
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        if(isSearching) {
            cell.textLabel?.text = searchedElement[indexPath.row]
        } else if appData.selectedScope == 1 && appData.categoriesToSearch.count > indexPath.row {
            cell.textLabel?.text = appData.categoriesToSearch[indexPath.row]
        } else {
            cell.textLabel?.text = appData.locations[indexPath.row]
            cell.imageView?.image = nil
        }
        cell.textLabel?.textColor = #colorLiteral(red: 0.4504547798, green: 0.5101969303, blue: 0.689423382, alpha: 1)
        cell.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16)
//        cell.textLabel?.font = UIFont(name: "Avenir Next", size: 16)
        
        
        // Adds boarder to table cells
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 4
        cell.layer.borderWidth = 1
        cell.layer.shadowOffset = CGSize(width: -1, height: 1)
        let borderColor: UIColor = UIColor(red:0.72, green:0.76, blue:0.88, alpha:1.0)
        cell.layer.borderColor = borderColor.cgColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(appData.selectedScope == 2) {
            return 75.0
        } else {
            return 50.0
        }
    }
    
    // Tracks what user selects as interesting in the search function.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let instanceOfJson = JSONController()
        
        // Resets the top 5 tweets info
        appData.top5Username = []
        appData.links = []
        appData.top5 = []
        
        appData.specificTweets = []
        appData.specificTweetText = []
        appData.specificTweetLinks = []
        
        // get data for location
        if(appData.selectedScope == 0) {
            
            // Looks at Location Data from dispatchFunc
            var currentCell = ""
            if(isSearching) {
                currentCell = searchedElement[indexPath.row]
            } else {
                currentCell = appData.locations[indexPath.row]
            }
            let jsonData = instanceOfJson.dispatchFunc(givenLocation: currentCell)
            var index = 0
            if(jsonData.count == 0) {
                let alert = UIAlertController(title: "Sorry!", message: "No Twitter Data for " + currentCell, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Search Another Location", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                while index <= 5 {
                    appData.top5Username.append(jsonData[index].name)
                    appData.links.append(jsonData[index].url)
                    appData.top5.append(" ")
                    index += 1
                }
                performSegue(withIdentifier: "goToResults", sender: self)
            }
        } else {
            // Looks at Location Data from dispatchFunc
            var currentCell = ""
            if(isSearching) {
                currentCell = searchedElement[indexPath.row]
            } else {
                currentCell = appData.categoriesToSearch[indexPath.row]
            }
            let jsonData = instanceOfJson.getTweetsWithHashtag(searchTopic: currentCell, numTweetsReturned: 5)
            var index = 0
            if(jsonData.count == 0) {
                let alert = UIAlertController(title: "Sorry!", message: "No Twitter Data for " + currentCell, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Search Another Term", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                while index < 5 {
                    appData.specificTweets.append(jsonData[index].name)
                    appData.specificTweetText.append(jsonData[index].text)
                    appData.specificTweetLinks.append(jsonData[index].url)
                    index += 1
                }
                performSegue(withIdentifier: "goToCatResult", sender: self)
            }
        }
    }
}

extension SearchVC: UISearchBarDelegate {
    
    // Function tracks if the user is searching
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Locations
        if(appData.selectedScope == 0) {
            searchedElement = appData.locations.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        } else {
            searchedElement = appData.categoriesToSearch.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        }
        isSearching = true
        tableView.reloadData()
    }
    
    // Tracks the selected scope on the scope bar
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        isSearching = false
        appData.selectedScope = selectedScope
        if(selectedScope == 0) {
            searchBar.placeholder = "Type city or country name!"
        } else {
            searchBar.placeholder = "Type category name!"
        }
        tableView.reloadData()
    }
    
    
    // Function used to pass in any location data or category data even if it is not listed
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        appData.searchButtonClicked = true
        if (searchBar.text! == "" ) {
            let alert = UIAlertController(title: "Sorry!", message: "Please specify your search!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            searchedElement = []
            if(appData.selectedScope == 0) {
                appData.locations.append(String(searchBar.text!))
            }else{
                appData.categoriesToSearch.append(String(searchBar.text!))
            }
            searchedElement.append(String(searchBar.text!))
            isSearching = true
            tableView.reloadData()
        }
    }
    
    
}
