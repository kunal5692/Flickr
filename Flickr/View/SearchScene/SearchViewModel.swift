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
    func reloadItemAtIndexPaths(indexPaths: [IndexPath])
}

protocol SearchViewModelInterface {
    
    func getServer(at index: Int) -> String
    
    func getSecret(at index: Int) -> String
    
    func getFarm(at index: Int) -> String
    
    func getPhotoId(at index: Int) -> String
    
    func getPhotosCount() -> Int
    
    func fetchPhotos(searchTerm query: String, page pageNo: Int)
    
    func getCellViewModel(at indexPath : IndexPath) -> PhotosCellViewModel?
    
    func removeAllPhotos()
    
    func didSelectItemAtIndex(at index : Int)
    
    var delegate : SearchViewModelDelegate? {get set}
}

class PhotosListViewModel : SearchViewModelInterface {
    public weak var delegate: SearchViewModelDelegate?
    private var photos : [Photo] = [Photo]()
    private let photosListProvider :ImageSearchResultDataProviderInterface
    private var cellViewModels : [PhotosCellViewModel] = [PhotosCellViewModel]()
    
    private var imageTasks = [Int : ImageDownloadTask]()
    
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
    
    func processPhotos(photos: [Photo]) {
        let previousCount = self.photos.count
        var indexPaths = [IndexPath]()
        var index = 0
        
        self.photos.append(contentsOf: photos)
        for photo in photos {
            self.cellViewModels.append(self.createCellViewModel(photo: photo))
            indexPaths.append(IndexPath(row: previousCount + index, section: 0))
            index += 1
        }
        
        self.isFetching = false
        self.delegate?.reloadItemAtIndexPaths(indexPaths: indexPaths)
        //self.delegate?.reloadCollectionView()
    }
    
    func fetchPhotos(searchTerm query: String, page pageNo: Int) {
        let processedQuery = self.processQuery(query: query)
        self.isFetching = true
        self.photosListProvider.fetchPhotos(processedQuery, page: pageNo, successHandler: { [weak self] (photos) in
            guard let strongSelf = self else {
                Logger.debug(LOGGER_TAG, "self is nil")
                return
            }
            
            if(photos.count == 0) {
                return
            }
            
            strongSelf.processPhotos(photos: photos)
            
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
    
    func getCellViewModel(at indexPath: IndexPath) -> PhotosCellViewModel? {
        if(self.cellViewModels.count > indexPath.row) {
            return self.cellViewModels[indexPath.row]
        }
        return nil
    }
    
    func removeAllPhotos() {
        if self.photos.count > 0 {
            self.photos.removeAll()
        }
        
        for cellViewModel in self.cellViewModels {
            cellViewModel.imageTask?.pause()
            cellViewModel.imageTask = nil
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

class PhotosCellViewModel {
    let id: String
    let farm: String
    let secret: String
    let server: String
    var imageTask: ImageDownloadTask?
    
    init(id: String, farm: String, secret: String, server: String) {
        self.id = id
        self.farm = farm
        self.secret = secret
        self.server = server
    }
    
    func setImageDownloadTask(position: Int, delegate: ImageDownloadedDelegate) {
        guard let url = URLBuilder.getImageFarmURL(farm: self.farm, id: self.id, secret: self.secret, server: self.server) else {
            return
        }
        
        let session = URLSession(configuration: .default)
        self.imageTask = ImageDownloadTask(position: position, url: url, session: session, delegate: delegate)
    }
}
