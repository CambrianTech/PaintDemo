//
//  SearchTableViewController.swift
//  HarmonyApp
//
//  Created by Jaremy Longley on 11/30/17.
//  Copyright © 2017 Cambrian. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

protocol SearchCellDelegate {
    func tryColorPressed(_ item: BrandItem)
    func seeMorePressed(_ section: Int)
}

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate, SearchCellDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
     @IBOutlet weak var categorySegmentedController: UISegmentedControl!
    var shownResults = List<BrandItem>()
    var shouldShowSearchResults = false
    var searchText: String!
    var sections = [Section]()
    var itemSelected: BrandItem?
    var itemCategorySelected: CBAssetType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //dismiss keyboard when table selected
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyobard))
        self.resultsTableView.addGestureRecognizer(tap)
        self.resultsTableView.dataSource = self
        self.resultsTableView.delegate = self
        self.resultsTableView.keyboardDismissMode = .onDrag
        self.resultsTableView.keyboardDismissMode = .interactive
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.navigationBar.barTintColor = appColor
        self.navigationController?.navigationBar.backgroundColor = appColor
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let segment = self.categorySegmentedController.selectedSegmentIndex
        self.itemCategorySelected = getSegmentType(segment)
        self.searchText = String()
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchBar.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.sections.isEmpty {
            return 0
        } else {
            let displaySection = self.sections[section]
            if displaySection.expanded {
                print(displaySection.items.count)
                return displaySection.getItemCount() + 2 // one more for the see more cell and one for the title
            } else if displaySection.items.count <= 3 {
                return displaySection.items.count + 1
            } else {
                return 5
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        let section = self.sections[indexPath.section]
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sectionTitleCell", for: indexPath) as? SectionTitleCell
            cell?.categoryTitle?.text = section.category
            return cell!
        } else if indexPath.row <= section.getItemCount() {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as? SearchResultCell
            // get the section that the rows are in
            cell?.item = section.items[indexPath.row - 1]
            cell?.delegate = self
            return cell!
        } else if indexPath.row == section.getItemCount() + 1 {     // This is the last cell, therefore the showMore cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "seeMoreCell") as? SeeMoreCell
            cell?.section = indexPath.section
            cell?.expanded = section.expanded
            cell?.delegate = self
            return cell!
        } else {
            fatalError("Could not find a cell")
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
//        self.shownResults = allResults.filter({ (array:String) -> Bool in
//            if array.contains(searchBar.text!) {
//                return true
//            } else {
//                return false
//            }
//        })
//        resultsTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        self.shownResults.removeAll()
        self.sections.removeAll()
        // Delay this request so that it is not constantly searching after every key press
        if !searchText.isEmpty {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reloadResults), object: nil)
            self.perform(#selector(self.reloadResults), with: nil, afterDelay: 0.5)
        } else {
            self.resultsTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ARViewController {
            if let item = self.itemSelected {
                vc.sendItem(item)
            }
        }
    }
    
    @IBAction func categorySegmentChanged(_ sender: Any) {
        let segment = self.categorySegmentedController.selectedSegmentIndex
        self.itemCategorySelected = getSegmentType(segment)
        self.reloadResults()
    }
    
    
    @objc func reloadResults() {
        if (!self.searchText.isEmpty) {
            self.shownResults = filterItems(searchText: self.searchText)
        }
        resultsTableView.reloadData()
    }
    
    func filterItems(searchText: String) -> List<BrandItem> {
        // predicates to search the name and storID and to only get paint (for now)
        var predicates = [
            "name": NSPredicate(format: "name contains[c] %@", searchText.lowercased()),
            "storeID": NSPredicate(format: "storeID contains[c] %@", searchText.lowercased())
        ]
        let context = DataController.sharedInstance.brandContext
        let compoundPred = NSCompoundPredicate(orPredicateWithSubpredicates: Array(predicates.values))
        let results = context?.objects(BrandItem.self).filter(compoundPred)
        let itemList = List<BrandItem>()
        if let results = results {
            for item in results {
                if item.type == self.itemCategorySelected {
                    itemList.append(item)
                    getSection(item)
                }
            }
        }
        return itemList
    }
    
    func getSection(_ item: BrandItem) {
        var added = false
        for section in self.sections {
            if section.category.contains(item.getRootCategory().name) {
                section.append(item)
                added = true
            }
        }
        if !added {
            var list = List<BrandItem>()
            list.append(item)
            let section = Section(category: item.getRootCategory().name, expanded: false, items: list)
            self.sections.append(section)
        }
    }
    
    // Cell Delegate Methods
    func tryColorPressed(_ item: BrandItem) {
        // Segue to visualizer with item in tow
        self.itemSelected = item
        self.performSegue(withIdentifier: "showVisualizer", sender: self)
    }
    
    func seeMorePressed(_ section: Int) {
        // Expand the cell
        let expanded = !sections[section].expanded
        //Toggle collapse
        sections[section].expanded = expanded
        
        self.resultsTableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
    }
    
    @objc func dismissKeyobard() {
        self.searchBar.resignFirstResponder()
    }
    
    func getSegmentType(_ segment: Int) -> CBAssetType{
        self.sections.removeAll()
        switch segment {
        case 0:
            return .paint
        case 1:
            return .floor
        default:
            return .paint
        }
    }
    
}

class SectionTitleCell: UITableViewCell {
    @IBOutlet weak var categoryTitle: UILabel!
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        self.categoryTitle.font.withSize(25.0)
//    }
}

class SearchResultCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var itemThumbnail: UIImageView!
    @IBOutlet weak var tryItButton: UIButton!
    
    var delegate: SearchCellDelegate?
    
    var item: BrandItem! {
        didSet {
            update()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        itemThumbnail.layer.cornerRadius = 8.0
        itemThumbnail.clipsToBounds = true
        itemThumbnail.isUserInteractionEnabled = true
        tryItButton.layer.cornerRadius = 8.0
        tryItButton.clipsToBounds = true
        tryItButton.isUserInteractionEnabled = true
    }
    
    func update() {
        title.text = item.name
        itemThumbnail.backgroundColor = item.color
        itemThumbnail.kf.setImage(with: item.getThumbnailPath())
    }
    
    @IBAction func tryItPressed(_ sender: Any) {
        if let item = self.item {
            delegate?.tryColorPressed(item)
        }
    }
}

class SeeMoreCell: UITableViewCell {
    @IBOutlet weak var seeMoreButton: UIButton!
    @IBOutlet weak var chevron: UIButton!
    var expanded: Bool? {
        didSet {
            let size = expanded! ? -1.0 : 1.0
            chevron.transform = CGAffineTransform(scaleX: 1, y: CGFloat(size))
            seeMoreButton.titleLabel?.text = expanded! ? "See Less" : "See More"
        }
    }
    var section: Int = 0
    
    var delegate: SearchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func seeMorePressed(_ sender: Any) {
        delegate?.seeMorePressed(self.section)
    }
    
    @IBAction func chevronPressed(_ sender: Any) {
        delegate?.seeMorePressed(self.section)
    }
    
}





