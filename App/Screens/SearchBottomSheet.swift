//
//  SearchBottomSheet.swift
//  HarmonyApp
//
//  Created by Jaremy Longley on 12/7/17.
//  Copyright © 2017 Cambrian. All rights reserved.
//

import Foundation
import RealmSwift

class SearchBottomSheet: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var showHideLabel: UIButton!
    var sections = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sectionTitleCell", for: indexPath) as? SectionTitleCell
            cell?.categoryTitle?.text = section.category
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "productCollectionCell") as? ProductCollectionViewCell
            return cell!
        }
    }
}

class ProductCollectionViewCell: UITableViewCell, UICollectionViewDataSource {
    
    @IBOutlet weak var productCollection: UICollectionView!
    var sections = [Section]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCollectionItemCell", for: indexPath) as? ProductCollectionItemCell else {
            fatalError("Could not find cell")
        }
        cell.item = self.sections[indexPath.section].items[indexPath.item]
        return cell
    }
    
    
}

class ProductCollectionItemCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    
    var item: BrandItem? {
        didSet {
            self.itemImage.backgroundColor = item?.color
            self.itemName.text = item?.name
            itemImage.kf.setImage(with: item?.getThumbnailPath())
        }
    }
}



