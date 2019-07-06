//
//  ImageDownloadTask.swift
//  Flickr
//
//  Created by kunal.ch on 05/07/19.
//  Copyright © 2019 kunal.ch. All rights reserved.
//

import Foundation
import UIKit

protocol ImageDownloadedDelegate {
    func downloadCompleted(position: Int)
}

class CacheManager {
    let imageCache : NSCache<AnyObject, AnyObject>
    static let shared = CacheManager()
    private init() {
        self.imageCache = NSCache<AnyObject, AnyObject>()
    }
}

class ImageDownloadTask {
    let delegate: ImageDownloadedDelegate
    let position: Int
    let url : URL
    let session: URLSession
    var image: UIImage?
    
    private var task: URLSessionDownloadTask?
    private var resumeData: Data?
    
    private var isDownloading: Bool = false
    private var isFinishedDownloading : Bool = false
    
    init(position: Int, url : URL, session: URLSession, delegate: ImageDownloadedDelegate) {
        self.position = position
        self.url = url
        self.session = session
        self.delegate = delegate
    }

    func resume() {
        if !isDownloading && !isFinishedDownloading {
            self.isDownloading = true
            
            if let resumeData = resumeData {
                task = session.downloadTask(withResumeData: resumeData, completionHandler: downloadTaskCompletionHandler)
            } else {
                task = session.downloadTask(with: url, completionHandler: downloadTaskCompletionHandler)
            }
            
            task?.resume()
        }
    }
    
    func pause() {
        if isDownloading && !isFinishedDownloading {
            task?.cancel(byProducingResumeData: { (data) in
                self.resumeData = data
            })
            
            self.isDownloading = false
        }
    }
    
    private func downloadTaskCompletionHandler(url: URL?, response: URLResponse?, error: Error?) {
        if let error = error {
            print("Error downloading: ", error)
            return
        }
        
        guard let url = url else { return }
        
        if let imageFromCache = CacheManager.shared.imageCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
            DispatchQueue.main.async {
                self.image = imageFromCache
                self.delegate.downloadCompleted(position: self.position)
            }
            return
        }
        
        guard let data = FileManager.default.contents(atPath: url.path) else { return }
        guard let image = UIImage(data: data) else { return }
        
        DispatchQueue.main.async {
            CacheManager.shared.imageCache.setObject(image, forKey: url.absoluteString as AnyObject)
            self.image = image
            self.delegate.downloadCompleted(position: self.position)
        }
        
        self.isFinishedDownloading = true
    }
}
