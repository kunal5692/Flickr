//
//  PhotosCell.swift
//  Flickr
//
//  Created by kunal.ch on 30/06/19.
//  Copyright © 2019 kunal.ch. All rights reserved.
//

import UIKit

fileprivate let LOGGER_TAG = "##PhotosCell##"

class PhotosCell: UICollectionViewCell, ImageDownloadedDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
  //  private var secret : String?
  //  private var farm : String?
  //  private var id : String?
  //  private var server : String?
   
    var indexPath: IndexPath?
    
    private lazy var spinner : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var retry : UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
        btn.setTitle("Retry", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(retryPressed), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isHidden = true
        return  btn
    }()
    
    var photoCellViewModel : PhotosCellViewModel? {
        didSet{
            photoCellViewModel?.setImageDownloadTask(position: indexPath?.row ?? 0 , delegate: self)
            
            // Reset image for reused cell
            self.imageView.image = nil
            
    //        secret = photoCellViewModel?.secret
    //        farm = photoCellViewModel?.farm
    //        id = photoCellViewModel?.id
    //        server = photoCellViewModel?.server
            self.spinner.startAnimating()
            //self.loadImage()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.containerView.addSubview(self.spinner)
        self.containerView.addSubview(self.retry)
        self.retry.isHidden = true
        self.setupConstraints()
    }
    
    @objc func retryPressed() {
        self.loadImage()
    }
    
    func setupConstraints() {
        // Spinner constraints
        let spinnerHorizontalConstraint = NSLayoutConstraint(item: self.spinner,
                                                             attribute: .centerX,
                                                             relatedBy: .equal,
                                                             toItem: self.containerView,
                                                             attribute: .centerX,
                                                             multiplier: 1,
                                                             constant: 0)
        
        let spinnerVerticalConstraint = NSLayoutConstraint(item: self.spinner,
                                                           attribute: .centerY,
                                                           relatedBy: .equal,
                                                           toItem: self.containerView,
                                                           attribute: .centerY,
                                                           multiplier: 1.0,
                                                           constant: 0)
        
        NSLayoutConstraint.activate([spinnerVerticalConstraint, spinnerHorizontalConstraint])
        
        // Retry constraint
        
        let retryHorizontalConstraint = NSLayoutConstraint(item: self.retry,
                                                             attribute: .centerX,
                                                             relatedBy: .equal,
                                                             toItem: self.containerView,
                                                             attribute: .centerX,
                                                             multiplier: 1,
                                                             constant: 0)
        
        let retryVerticalConstraint = NSLayoutConstraint(item: self.retry,
                                                           attribute: .centerY,
                                                           relatedBy: .equal,
                                                           toItem: self.containerView,
                                                           attribute: .centerY,
                                                           multiplier: 1.0,
                                                           constant: 0)
        
        NSLayoutConstraint.activate([retryHorizontalConstraint, retryVerticalConstraint])

    }
    
    func loadImage() {
        self.retry.isHidden = true
        
        guard let url = URLBuilder.getImageFarmURL(farm: farm!, id: id!, secret: secret!, server: server!) else {
            return
        }
        
        Logger.debug(LOGGER_TAG, "Loading image for url \(url.absoluteString)")
        self.imageView.downloadAndCacheImage(url: url, completion: { [weak self] in
            Logger.debug(LOGGER_TAG, "Downloaded image")
            guard let strongSelf = self else {
                return
            }
            strongSelf.spinner.stopAnimating()
            strongSelf.retry.isHidden = true
            
        }, failure: { [weak self] in
            Logger.debug(LOGGER_TAG, "Failed to download image")
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.retry.isHidden = false
            strongSelf.spinner.stopAnimating()
        })
    */
        
    }
    
    func downloadCompleted(position: Int) {
        Logger.debug(LOGGER_TAG, "Downloaded image at \(position)")
        if(indexPath?.row == position) {
            self.spinner.stopAnimating()
            self.imageView.image = self.photoCellViewModel?.imageTask?.image
        }
    }
}
