//
//  URLBuilder.swift
//  Flickr
//
//  Created by kunal.ch on 29/06/19.
//  Copyright © 2019 kunal.ch. All rights reserved.
//

import Foundation

/*
 * Sample Api call
 * https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3e7cc266ae2b0e0d78e279ce8e361736&&format=json&nojsoncallback=1&safe_search=1&text=kittens
 *
 */

enum FlickrApiMethod : String {
    case SEARCH = "flickr.photos.search"
}

enum FlickrApiResponseFormat : String {
    case JSON = "json"
    case XML = "xml"
}


class URLBuilder {
    
    private let baseURLString = "https://api.flickr.com/services/rest"
    
    static func getPhotosURL(search query: String, page pageNo: Int) -> URL? {
        
        guard let baseurl = self.getBaseRestServiceURL() else {
            return nil
        }
        
        var components = URLComponents(url: baseurl , resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "method", value: FlickrApiMethod.SEARCH.rawValue),
            URLQueryItem(name: "api_key", value: Constants.API_KEY),
            URLQueryItem(name: "format", value: FlickrApiResponseFormat.JSON.rawValue),
            URLQueryItem(name: "nojsoncallback", value: "1"),
            URLQueryItem(name: "safe_search", value: "1"),
            URLQueryItem(name: "page", value: String(pageNo)),
            URLQueryItem(name: "text", value: query)
        ]
        return components?.url
    }
    
    static func getBaseRestServiceURL() -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest"
        return components.url
    }
    
    static func getImageFarmURL(farm : String, id : String, secret : String, server : String) -> URL? {
        debugPrint("SECRET: \(secret)")
        debugPrint("SERVER: \(server)")
        debugPrint("FARM: \(farm)")
        debugPrint("ID: \(id)")
        
        let host = "farm" + farm + "." + Constants.IMAGE_FARM_HOST
        let path = "/" + server + "/" + id + "_" + secret
        return URL(string: "http://\(host)\(path).jpg")
    }
}
