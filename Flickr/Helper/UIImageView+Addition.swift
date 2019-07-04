//
//  UIImageView+Addition.swift
//  Flickr
//
//  Created by kunal.ch on 30/06/19.
//  Copyright © 2019 kunal.ch. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func downloadAndCacheImage(url : URL, completion completionHandler: @escaping () -> Void, failure failureHandler: @escaping () -> Void) {
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
            DispatchQueue.main.async {
                self.image = imageFromCache
                completionHandler()
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        failureHandler()
                    }
                    
                    return
            }
            
            DispatchQueue.main.async {
                imageCache.setObject(image, forKey: url.absoluteString as AnyObject)
                self.image = image
                completionHandler()
            }
            }.resume()
    }
}
