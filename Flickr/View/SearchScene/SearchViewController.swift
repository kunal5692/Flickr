//
//  SearchViewController.swift
//  Flickr
//
//  Created by kunal.ch on 29/06/19.
//  Copyright © 2019 kunal.ch. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    // View model for view controller
    private var searchViewModel : SearchViewModelInterface?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        debugPrint("Started application")
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.setUpViewModel()
        self.setUpSearchBar()
    }
    
    private func setUpViewModel() {
        let dataProvider = ImageSearchResultDataProvider.init(flickrAPI: FlickrApi.shared)
        searchViewModel = PhotosListViewModel(dataProvider: dataProvider)
        searchViewModel?.delegate = self
        //searchViewModel?.fetchPhotos(searchTerm: "", page: "")
    }
    
    func setUpSearchBar() {
        self.searchBar.delegate = self
    }
}

extension SearchViewController : SearchViewModelDelegate {
    func errorWhileFetchingPhotos(error: NSError) {
        
    }
    
    func reloadCollectionView() {
        debugPrint("Reload collection view")
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func updateFetchingStatus() {
        
    }
    
    func didSelectContact(photo: Photo) {
        
    }
}

extension SearchViewController : UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        debugPrint("Search bar end editing")
        guard let query = searchBar.text else {
            return
        }
        
        if(query.isEmpty) {
            return
        }
        
        self.search(searchTerm: query)
    }
    
    /*
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    */
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        debugPrint("Search button pressed")
        guard let query = searchBar.text else {
            return
        }
        
        if(query.isEmpty) {
            return
        }
        
        self.search(searchTerm: query)
    }
    
    /*
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    */
    
    func search(searchTerm query : String) {
        debugPrint("Searching for term ", query)
        guard let searchVM = self.searchViewModel else {
            debugPrint("Returing as view model is nil")
            return
        }
        
        searchVM.fetchPhotos(searchTerm: query, page: 0)
    }
    
}


extension SearchViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let vm = self.searchViewModel else {
            return 0
        }
        
        return vm.getPhotosCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.PHOTO_CELL_IDENTIFIER, for: indexPath) as? PhotosCell else {
            fatalError("Cell does not exist")
        }
        
        guard let searchVM = self.searchViewModel else {
            fatalError("View model is nil")
        }
        
        let cellVM = searchVM.getCellViewModel(at: indexPath)
        cell.photoCellViewModel = cellVM
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = self.collectionView.bounds.size.width;
        let cellWidth = screenWidth / 3.0
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
