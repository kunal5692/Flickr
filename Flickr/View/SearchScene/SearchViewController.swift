//
//  SearchViewController.swift
//  Flickr
//
//  Created by kunal.ch on 29/06/19.
//  Copyright © 2019 kunal.ch. All rights reserved.
//

import UIKit

fileprivate let LOGGER_TAG = "##SearchViewController##"

class SearchViewController: UIViewController, DetailImageViewRoute, ErrorAlertViewRoute {

    // View model for view controller
    private var searchViewModel : SearchViewModelInterface?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    // Default page number of flickr is 1
    private var page : Int = 1
    private var currentSearchQuery : String = ""
    private var isCollectionViewFetching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.setUpViewModel()
        self.setUpSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func setUpViewModel() {
        let dataProvider = ImageSearchResultDataProvider.init(flickrAPI: FlickrApi.shared)
        searchViewModel = PhotosListViewModel(dataProvider: dataProvider)
        searchViewModel?.delegate = self
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
        openAlertView(message: error.debugDescription, title: "Error")
    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func updateFetchingStatus(fetching : Bool) {
        self.isCollectionViewFetching = fetching
    }
    
    func didSelectContact(photo: Photo) {
        openDetailImageView(for: photo)
    }
    
    func reloadItemAtIndexPaths(indexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            self.collectionView.insertItems(at: indexPaths)
        }
    }
}

extension SearchViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        Logger.debug(LOGGER_TAG, "Search button pressed")
        Logger.debug(LOGGER_TAG, "Seraching for \(String(describing: searchBar.text))")
        searchBar.resignFirstResponder()
        
        guard let query = searchBar.text else {
            return
        }
        
        // Return is query is empty or equal to current search query
        if(query.isEmpty || query == self.currentSearchQuery) {
            return
        }
        
        if let vm = self.searchViewModel {
            // Reset page count
            self.page = 1
            // Remove all photos
            vm.removeAllPhotos()
        }
        
        self.currentSearchQuery = query
        self.search(searchTerm: query)
    }
    
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vm = self.searchViewModel {
            vm.didSelectItemAtIndex(at : indexPath.row)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.endEditing(true)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        Logger.debug(LOGGER_TAG, "End dragging")
        let height = self.view.bounds.height
        let offset = targetContentOffset.pointee.y + height
        let contentHeight = scrollView.contentSize.height
        
        if(contentHeight > height && offset > contentHeight - height && !self.isCollectionViewFetching) {
            self.page += 1
            self.search(searchTerm: self.currentSearchQuery)
        }
    }
}
