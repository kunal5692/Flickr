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
    func openAlertView(message: String, title: String)
}

extension DetailImageViewRoute where Self: UIViewController {
    func openDetailImageView(for photo: Photo) {
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "detail_vc") as! DetailViewController
        detailVC.photo = photo
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension ErrorAlertViewRoute where Self: UIViewController {
    func openAlertView(message: String, title: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
        }
        alertView.addAction(okAction)
        present(alertView, animated: true, completion: nil)
    }
}
