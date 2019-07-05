//
//  FlickrApi.swift
//  Flickr
//
//  Created by kunal.ch on 29/06/19.
//  Copyright © 2019 kunal.ch. All rights reserved.
//

import Foundation
import UIKit

fileprivate let LOGGER_TAG = "##FlickrApi##"
fileprivate let ErrorDomain = "FlickrApi.error"
public typealias ErrorHandler = (NSError) -> Void

// MARK: Request error code
public enum FlickrApiErrCode : Int {
    case NetworkNotReachable
    case GenericError
    case InvalidResponse
    case UnsupportedStatusCode
    case FailedToDecodeResponse
    case URLBuilderFailure
}

protocol FlickrApiInterface {
    /*
     * Fetches photos from flickr API that match the search term
     */
    func fetchPhotos(_ searchTerm: String, page pageNo: Int, successHandler : @escaping ([Photo]) -> Void, errorHandler : @escaping ErrorHandler)
}

class FlickrApi: FlickrApiInterface {
    let defaultSession = URLSession(configuration: .default)
    var dataTask : URLSessionDataTask?
    
    /**
     A global shared FlickAPI Instance.
     */
    static public let shared: FlickrApi = FlickrApi()
    
    /**
     Fetch Flickr photos list based on a given search term.
     
     - parameter searchTerm: A string to match images against.
     - paramter ppageNo: Current page index
     - parameter completionHandler: The closure invoked when fetching is completed and the image search results are given.
     */
    
    func fetchPhotos(_ searchTerm: String, page pageNo: Int, successHandler: @escaping ([Photo]) -> Void, errorHandler: @escaping ErrorHandler) {
        guard let url = URLBuilder.getPhotosURL(search: searchTerm, page: pageNo) else {
            errorHandler(NSError(domain: ErrorDomain, code: FlickrApiErrCode.URLBuilderFailure.rawValue, userInfo: nil))
            return
        }
        
        dataTask = defaultSession.dataTask(with: url) { data, response, error in
            // These will be the results we return with our completion handler
            var resultsToReturn = [Photo]()
            
            // Request error, set this object if request fails by any reason
            var reqErr : NSError? = nil
            
            // Ensure that our data task is cleaned up and our completion handler is called
            defer {
                self.dataTask = nil
                if(reqErr == nil) {
                    successHandler(resultsToReturn)
                }else {
                    errorHandler(reqErr!)
                }
            }
            
            if let error = error {
                Logger.debug(LOGGER_TAG, "[API] Request failed with error: \(error.localizedDescription)")
                reqErr = error as NSError
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                Logger.debug(LOGGER_TAG, "[API] Request returned an invalid response")
                reqErr = NSError(domain: ErrorDomain, code: FlickrApiErrCode.InvalidResponse.rawValue, userInfo: nil)
                return
            }
            
            guard response.statusCode == 200 else {
                Logger.debug(LOGGER_TAG, "[API] Request returned an unsupported status code: \(response.statusCode)")
                reqErr = NSError(domain: ErrorDomain, code: FlickrApiErrCode.UnsupportedStatusCode.rawValue, userInfo: nil)
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                 let result = try decoder.decode(SearchResult.self, from: data)
                 resultsToReturn = result.photos.photo
            }catch {
                Logger.debug(LOGGER_TAG, "[API] Decoding failed with error: \(error)")
                reqErr = NSError(domain: ErrorDomain, code: FlickrApiErrCode.FailedToDecodeResponse.rawValue, userInfo: nil)
            }
        }
    
        dataTask?.resume()
    }
}
