//
//  Router.swift
//  Flickr
//
//  Created by kunal.ch on 05/07/19.
//  Copyright © 2019 kunal.ch. All rights reserved.
//

import Foundation
import UIKit

protocol DetailImageViewRoute {
    func openDetailImageView(for photo: Photo)
}

protocol ErrorAlertViewRoute {
    func openAlertView(error: NSError)
}

extension DetailImageViewRoute where Self: UIViewController {
    func openDetailImageView(for photo: Photo) {
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "detail_vc") as! DetailViewController
        detailVC.photo = photo
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension ErrorAlertViewRoute where Self: UIViewController {
    func openAlertView(error : NSError) {
        var title = "Error"
        var message = "Error"
        
        switch error.code {
        case -1009:
            title = "No connection"
            message = "Please connect to internet"
            break
    
        case FlickrApiErrCode.NoSearchResultsFound.rawValue:
            title = "Result Not Found"
            message = "Sorry we could not find any results for your search query"
            break
            
        case FlickrApiErrCode.GenericError.rawValue:
            title = error.userInfo["title"] as! String
            message = error.userInfo["message"] as! String
            break
            
        default:
            message = error.debugDescription
            break
        }
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
        }
        alertView.addAction(okAction)
        present(alertView, animated: true, completion: nil)
    }
}
