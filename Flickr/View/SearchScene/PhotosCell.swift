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
            // Set image task
            photoCellViewModel?.setImageDownloadTask(position: indexPath?.row ?? 0 , delegate: self)
            // Reset image for reused cell
            self.imageView.image = nil
            // Hide retry button
            self.retry.isHidden = true
            // Start animating spinner
            self.spinner.startAnimating()
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
        self.retry.isHidden = true
        self.spinner.startAnimating()
        self.photoCellViewModel?.imageTask?.resume()
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
    
    func downloadCompleted(position: Int) {
        Logger.debug(LOGGER_TAG, "Downloaded image at \(position)")
        if(indexPath?.row == position) {
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.retry.isHidden = true
                self.imageView.image = self.photoCellViewModel?.imageTask?.image
            }
        }
    }
    
    func downloadingFailed(position: Int, error: Error) {
        Logger.debug(LOGGER_TAG, "Failed downloading at \(position)")
        if(indexPath?.row == position) {
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.retry.isHidden = false
            }
        }
    }
}
