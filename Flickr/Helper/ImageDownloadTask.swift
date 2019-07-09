//
//  ImageDownloadTask.swift
//  Flickr
//
//  Created by kunal.ch on 05/07/19.
//  Copyright © 2019 kunal.ch. All rights reserved.
//

import Foundation
import UIKit

fileprivate let TAG = "##TASK##"

protocol ImageDownloadedDelegate {
    func downloadCompleted(position: Int)
    func downloadingFailed(position: Int, error : Error)
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
        Logger.debug(TAG, "Starting download")
        if let imageFromCache = CacheManager.shared.imageCache.object(forKey: self.url.absoluteString as AnyObject) as? UIImage {
            Logger.debug("TASK", "Got from cache")
            DispatchQueue.main.async {
                Logger.debug("TASK", "Returing from cache")
                self.image = imageFromCache
                self.delegate.downloadCompleted(position: self.position)
            }
            return
        }
        
        if !isDownloading && !isFinishedDownloading {
            self.isDownloading = true
            
            if let resumeData = resumeData {
                Logger.debug(TAG, "Resuming download")
                task = session.downloadTask(withResumeData: resumeData, completionHandler: downloadTaskCompletionHandler)
            } else {
                Logger.debug(TAG, "Downloading from url \(url)")
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
            Logger.debug("TASK", "Error downloading: \(error)")
            self.isDownloading = false
            self.delegate.downloadingFailed(position: self.position, error: error)
            return
        }
        
        guard let url = url else { return }
        guard let data = FileManager.default.contents(atPath: url.path) else { return }
        guard let image = UIImage(data: data) else { return }
        
        CacheManager.shared.imageCache.setObject(image, forKey: self.url.absoluteString as AnyObject)
        self.image = image
        self.isFinishedDownloading = true
        self.delegate.downloadCompleted(position: self.position)
    }
}
