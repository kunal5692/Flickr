//
//  StubsGenerator.swift
//  FlickrTests
//
//  Created by kunal.ch on 08/07/19.
//  Copyright © 2019 kunal.ch. All rights reserved.
//

import Foundation
@testable import Flickr

class StubsGenertor {
    
    static func generatePhotosStub() -> [Photo] {
        var photos = [Photo]()
        let photoDicts = [
            [
                "id": "48230545406",
                "owner": "146350239@N08",
                "secret": "4f71f6e08b",
                "server": "65535",
                "farm": 66,
                "title": "Hello there",
                "ispublic": 1,
                "isfriend": 0,
                "isfamily": 0
            ],
            [
                "id": "48229504797",
                "owner": "120294943@N04",
                "secret": "a650408a12",
                "server": "65535",
                "farm": 66,
                "title": "Majesty- The Nautical Experience",
                "ispublic": 1,
                "isfriend": 0,
                "isfamily": 0
            ],
            [
                "id": "48229900887",
                "owner": "165597630@N04",
                "secret": "d9d72fe756",
                "server": "65535",
                "farm": 66,
                "title": "Tẩy trang Muji có tốt không? Giá bao nhiêu",
                "ispublic": 1,
                "isfriend": 0,
                "isfamily": 0
            ],
            [
                "id": "48229878502",
                "owner": "91151736@N02",
                "secret": "977acdf10b",
                "server": "65535",
                "farm": 66,
                "title": "Lady Pink",
                "ispublic": 1,
                "isfriend": 0,
                "isfamily": 0
            ],
            [
                "id": "48229481837",
                "owner": "165776643@N06",
                "secret": "8a7dfc6afa",
                "server": "65535",
                "farm": 66,
                "title": "DELSU Admission List for 2019/2020 Session",
                "ispublic": 1,
                "isfriend": 0,
                "isfamily": 0
            ],
            [
                "id": "48229252297",
                "owner": "40374961@N00",
                "secret": "0c1b579389",
                "server": "65535",
                "farm": 66,
                "title": "Tres Blah C88 July 2019",
                "ispublic": 1,
                "isfriend": 0,
                "isfamily": 0
            ],
        ]
    
        
        for photoDict in photoDicts {
            photos.append( Photo( id: photoDict["id"] as! String,
                                  owner: photoDict["owner"] as! String,
                                  secret: photoDict["secret"] as! String,
                                  server: photoDict["server"] as! String,
                                  farm: photoDict["farm"] as! Int,
                                  title: photoDict["title"] as! String,
                                  isPublic: photoDict["ispublic"] as! Int,
                                  isFriend: photoDict["isfriend"] as! Int,
                                  isFamily: photoDict["isfamily"] as! Int))
        }
        
        return photos
    }
}
