//
//  ImageSearchResultDataProvider.swift
//  Flickr
//
//  Created by kunal.ch on 29/06/19.
//  Copyright © 2019 kunal.ch. All rights reserved.
//

import Foundation

// MARK: = Interfaces
protocol ImageSearchResultDataProviderInterface {
    /*
     * Fetches users from that match a given a search term
     */
    func fetchPhotos(_ searchTerm: String, page pageNo: Int, successHandler: @escaping ([Photo]) -> Void, errorHandler : @escaping ErrorHandler)
}

class ImageSearchResultDataProvider: ImageSearchResultDataProviderInterface {
    var flickrAPI: FlickrApiInterface
    
    init(flickrAPI : FlickrApiInterface) {
        self.flickrAPI = flickrAPI
    }
    
    func fetchPhotos(_ searchTerm: String, page pageNo: Int, successHandler: @escaping ([Photo]) -> Void, errorHandler: @escaping ErrorHandler) {
        self.flickrAPI.fetchPhotos(searchTerm, page: pageNo, successHandler: { (photos) in
            successHandler(photos)
        }) { (error) in
            errorHandler(error)
        }
    }
}
