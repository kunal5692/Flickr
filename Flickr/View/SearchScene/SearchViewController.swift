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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        debugPrint("Started application")
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.setUpViewModel()
    }
    
    private func setUpViewModel() {
        let dataProvider = ImageSearchResultDataProvider.init(flickrAPI: FlickrApi.shared)
        searchViewModel = PhotosListViewModel(dataProvider: dataProvider)
        searchViewModel?.delegate = self
        //searchViewModel?.fetchPhotos(searchTerm: "", page: "")
    }
}

extension SearchViewController : SearchViewModelDelegate {
    func errorWhileFetchingPhotos(error: NSError) {
        
    }
    
    func reloadCollectionView() {
        
    }
    
    func updateFetchingStatus() {
        
    }
    
    func didSelectContact(photo: Photo) {
        
    }
}

extension SearchViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // TODO
        return UICollectionViewCell()
    }
}
