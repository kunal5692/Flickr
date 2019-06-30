//
//  PhotosCell.swift
//  Flickr
//
//  Created by kunal.ch on 30/06/19.
//  Copyright © 2019 kunal.ch. All rights reserved.
//

import UIKit

class PhotosCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    private var secret : String?
    private var farm : String?
    private var id : String?
    private var server : String?
    
    var photoCellViewModel : PhotosCellViewModel? {
        didSet{
            secret = photoCellViewModel?.secret
            farm = photoCellViewModel?.farm
            id = photoCellViewModel?.id
            server = photoCellViewModel?.server
            self.loadImage()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        debugPrint("Awake from NIB")
    }
    
    func loadImage() {
        debugPrint("Load images")
        guard let url = URLBuilder.getImageFarmURL(farm: farm!, id: id!, secret: secret!, server: server!) else {
            return
        }
        debugPrint("Loading image for url ", url.absoluteString)
        self.imageView.downloadAndCacheImage(url: url)
    }
}
