//
//  FlickrTests.swift
//  FlickrTests
//
//  Created by kunal.ch on 29/06/19.
//  Copyright © 2019 kunal.ch. All rights reserved.
//

import XCTest
@testable import Flickr

class FlickrTests: XCTestCase {

    var mockApiService: MockApiService?
    
    var dataProvider: ImageSearchResultDataProvider?
    var photoListViewModel: PhotosListViewModel?

    
    override func setUp() {
        super.setUp()
        mockApiService = MockApiService()
        dataProvider = ImageSearchResultDataProvider(flickrAPI: mockApiService!)
        photoListViewModel = PhotosListViewModel(dataProvider: dataProvider!)
    }

    override func tearDown() {
        super.tearDown()
        photoListViewModel = nil
        mockApiService = nil
        dataProvider = nil
    }

    // Tests view model behaviour
    func testViewModelBehaviour() {
        photoListViewModel?.fetchPhotos(searchTerm: "https://dummy.com", page: 1)
        XCTAssert(mockApiService!.isFetchPhotosCalled)
    }
    
    // Test data provider success callback
    func testDataProviderSuccess() {
        mockApiService!.isSuccessCase = true
       
        dataProvider?.fetchPhotos("dummy", page: 1, successHandler: { (photo) in
            XCTAssert(photo.count > 0)
        }, errorHandler: { (error) in
            XCTAssertNil(error)
        })
    }
    
    // Tests data provide failure callback
    func testDataProviderFailure() {
        mockApiService?.isSuccessCase = false
        
        dataProvider?.fetchPhotos("dummy", page: 1, successHandler: { (photo) in
            XCTAssert(photo.count == 0)
        }, errorHandler: { (error) in
            XCTAssert(error.code == 1)
        })
    }
    
    // Tests data provider data correctness
    func testDataProviderDataCorrectness() {
        mockApiService?.isSuccessCase = true
        
        dataProvider?.fetchPhotos("dummy", page: 1, successHandler: { (photos) in
            
            let stubbedPhotos = StubsGenertor.generatePhotosStub()
            
            let randomPhotoObjectFromResponse = photos[2]
            let randomPhotoObjectFromStubbedPhotos = stubbedPhotos[2]
            
            XCTAssertEqual(randomPhotoObjectFromResponse.id, randomPhotoObjectFromStubbedPhotos.id)
            
        }, errorHandler: { (error) in
            XCTAssertNil(error)
        })
    }
    
    func testImageURLBuilder() {
        mockApiService?.isSuccessCase = true
        
        dataProvider?.fetchPhotos("dummy", page: 1, successHandler: { (photos) in
            
            let photo = photos[2]
            
            let url = URLBuilder.getImageFarmURL(farm: String(photo.farm), id: photo.id, secret: photo.secret, server: photo.server, size: "b")
            
            let urlComponents = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            let expectedHost = "farm" + String(photo.farm) + ".static.flickr.com"
            let expectedPathParam1 = photo.server
            let exprectedPathParam2 = photo.id + "_" + photo.secret + "_b.jpg"
            
            let actualHost = urlComponents?.host
            let paths = urlComponents?.path.components(separatedBy: "/")
            
            XCTAssertEqual(expectedHost, actualHost)
            XCTAssertEqual(expectedPathParam1, paths![1])
            XCTAssertEqual(exprectedPathParam2, paths![3])
            
        }, errorHandler: { (error) in
            XCTAssertNil(error)
        })
    }
}
