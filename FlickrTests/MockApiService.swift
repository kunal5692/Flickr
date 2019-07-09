//
//  MockApiService.swift
//  FlickrTests
//
//  Created by kunal.ch on 08/07/19.
//  Copyright © 2019 kunal.ch. All rights reserved.
//

import Foundation
@testable import Flickr

class MockApiService: FlickrApiInterface {
    
    var isFetchPhotosCalled = false
    
    var successClosure : (([Photo]) -> Void)?
    
    var failureClousre : ErrorHandler?
    
    var isSuccessCase : Bool = true
    
    func fetchPhotos(_ searchTerm: String, page pageNo: Int, successHandler: @escaping ([Photo]) -> Void, errorHandler: @escaping ErrorHandler) {
        isFetchPhotosCalled = true
        if isSuccessCase {
            let photos = StubsGenertor.generatePhotosStub()
            successHandler(photos)
        }else {
            let error : NSError = NSError(domain: "flickr_test" , code: 1, userInfo: nil)
            errorHandler(error)
        }
    }
}
