//
//  DetailViewController.swift
//  Flickr
//
//  Created by kunal.ch on 04/07/19.
//  Copyright © 2019 kunal.ch. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var photo: Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        guard let photoModel = self.photo else {
            return
        }
        
        guard let url = URLBuilder.getImageFarmURL(farm: String(photoModel.farm), id: photoModel.id, secret: photoModel.secret, server: photoModel.server) else {
            return
        }
        
        imageView.downloadAndCacheImage(url: url, completion: {
            //TODO
        }) {
            //TODO
        }
    }
    
}
