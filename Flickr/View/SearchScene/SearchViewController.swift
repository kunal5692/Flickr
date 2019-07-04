//
//  SearchViewController.swift
//  Flickr
//
//  Created by kunal.ch on 29/06/19.
//  Copyright © 2019 kunal.ch. All rights reserved.
//

import UIKit

fileprivate let LOGGER_TAG = "##SearchViewController##"

class SearchViewController: UIViewController {

    // View model for view controller
    private var searchViewModel : SearchViewModelInterface?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    private let page : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchBar.endEditing(true)
    }
}

extension SearchViewController : SearchViewModelDelegate {
    func errorWhileFetchingPhotos(error: NSError) {
        
    }
    
    func reloadCollectionView() {
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
        Logger.debug(LOGGER_TAG, "Search bar end editing")
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
        Logger.debug(LOGGER_TAG, "Search button pressed")
        
        if let vm = self.searchViewModel {
            vm.removeAllPhotos()
        }
        
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
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.resignFirstResponder()
        return true
    }
    
    func search(searchTerm query : String) {
        Logger.debug(LOGGER_TAG, "Searching for term \(query)")
        guard let searchVM = self.searchViewModel else {
            return
        }
        
        searchVM.fetchPhotos(searchTerm: query, page: self.page)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.endEditing(true)
    }
}
