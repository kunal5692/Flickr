//
//  DetailViewController.swift
//  Flickr
//
//  Created by kunal.ch on 04/07/19.
//  Copyright © 2019 kunal.ch. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, ErrorAlertViewRoute {

    @IBOutlet weak var imageView: UIImageView!
   
    private lazy var loader : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    
    var photo: Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let photoModel = self.photo else {
            return
        }
        self.view.addSubview(self.loader)
        
        // Spinner constraints
        let spinnerHorizontalConstraint = NSLayoutConstraint(item: self.loader,
                                                             attribute: .centerX,
                                                             relatedBy: .equal,
                                                             toItem: self.view,
                                                             attribute: .centerX,
                                                             multiplier: 1,
                                                             constant: 0)
        
        let spinnerVerticalConstraint = NSLayoutConstraint(item: self.loader,
                                                           attribute: .centerY,
                                                           relatedBy: .equal,
                                                           toItem: self.view,
                                                           attribute: .centerY,
                                                           multiplier: 1.0,
                                                           constant: 0)
        
        NSLayoutConstraint.activate([spinnerVerticalConstraint, spinnerHorizontalConstraint])
        
        self.loader.startAnimating()
        
        
        guard let url = URLBuilder.getImageFarmURL(farm: String(photoModel.farm), id: photoModel.id, secret: photoModel.secret, server: photoModel.server, size: "b") else {
            return
        }
        
        imageView.downloadAndCacheImage(url: url, completion: { [weak self] in
            self?.loader.stopAnimating()
        }) { [weak self] in
            self?.loader.stopAnimating()
            let error = NSError(domain: ErrorDomain, code: FlickrApiErrCode.GenericError.rawValue , userInfo: ["title" : "Loading Failed", "message" : "Failed to load image. Please check connection"])
            self?.openAlertView(error: error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
}
