//
//  SearchViewModel.swift
//  Flickr
//
//  Created by kunal.ch on 30/06/19.
//  Copyright © 2019 kunal.ch. All rights reserved.
//

import Foundation

fileprivate let LOGGER_TAG = "##SearchViewModel##"

protocol SearchViewModelDelegate : class {
    func errorWhileFetchingPhotos(error : NSError)
    func reloadCollectionView()
    func updateFetchingStatus(fetching : Bool)
    func didSelectContact(photo : Photo)
}

protocol SearchViewModelInterface {
    
    func getServer(at index: Int) -> String
    
    func getSecret(at index: Int) -> String
    
    func getFarm(at index: Int) -> String
    
    func getPhotoId(at index: Int) -> String
    
    func getPhotosCount() -> Int
    
    func fetchPhotos(searchTerm query: String, page pageNo: Int)
    
    func getCellViewModel(at indexPath : IndexPath) -> PhotosCellViewModel
    
    func removeAllPhotos()
    
    func didSelectItemAtIndex(at index : Int)
    
    var delegate : SearchViewModelDelegate? {get set}
}

class PhotosListViewModel : SearchViewModelInterface {
    public weak var delegate: SearchViewModelDelegate?
    private var photos : [Photo] = [Photo]()
    private let photosListProvider :ImageSearchResultDataProviderInterface
    private var cellViewModels : [PhotosCellViewModel] = [PhotosCellViewModel]()
    
    var isFetching: Bool = false {
        didSet {
            self.delegate?.updateFetchingStatus(fetching: isFetching)
        }
    }
    
    init(dataProvider : ImageSearchResultDataProviderInterface) {
        self.photosListProvider = dataProvider
    }
    
    func getServer(at index: Int) -> String {
        return photos[index].server
    }
    
    func getSecret(at index: Int) -> String {
        return photos[index].secret
    }
    
    func getFarm(at index: Int) -> String {
        return String(photos[index].farm)
    }
    
    func getPhotoId(at index: Int) -> String {
        return photos[index].id
    }
    
    func getPhotosCount() -> Int {
        return photos.count
    }
    
    func processQuery(query : String) -> String {
        return query.replacingOccurrences(of: " ", with: "+")
    }
    
    func fetchPhotos(searchTerm query: String, page pageNo: Int) {
        let processedQuery = self.processQuery(query: query)
        self.isFetching = true
        self.photosListProvider.fetchPhotos(processedQuery, page: pageNo, successHandler: { [weak self] (photos) in
            guard let strongSelf = self else {
                Logger.debug(LOGGER_TAG, "self is nil")
                return
            }
            strongSelf.photos.append(contentsOf: photos)
            for photo in strongSelf.photos {
                strongSelf.cellViewModels.append(strongSelf.createCellViewModel(photo: photo))
            }
            strongSelf.isFetching = false
            strongSelf.delegate?.reloadCollectionView()
            
        }) { [weak self] (error) in
            guard let strongSelf = self else {
                Logger.debug(LOGGER_TAG, "self is nil in error")
                return
            }
            strongSelf.isFetching = false
            strongSelf.delegate?.errorWhileFetchingPhotos(error: error)
        }
    }
    
    func createCellViewModel(photo : Photo) -> PhotosCellViewModel{
        return PhotosCellViewModel(id: photo.id, farm: String(photo.farm), secret: photo.secret, server: photo.server)
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> PhotosCellViewModel {
        return self.cellViewModels[indexPath.row]
    }
    
    func removeAllPhotos() {
        if self.photos.count > 0 {
            self.photos.removeAll()
        }
        
        if self.cellViewModels.count > 0 {
            self.cellViewModels.removeAll()
        }
        
        self.delegate?.reloadCollectionView()
    }
    
    func didSelectItemAtIndex(at index: Int) {
        if (self.photos.count != 0 && self.photos.count > index) {
            self.delegate?.didSelectContact(photo: self.photos[index])
        }
    }
}

struct PhotosCellViewModel {
    let id: String
    let farm: String
    let secret: String
    let server: String
}
