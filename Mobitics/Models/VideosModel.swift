//
//  VideosModel.swift
//  Mobitics
//
//  Created by Jagan on 26/12/19.
//  Copyright © 2019 Jagan. All rights reserved.
//

import UIKit

class VideosDataModel{
    var description:String?
    var id:String?
    var thumb:String?
    var title:String?
    var url:String?
    init(description:String?,id:String?,thumb:String?,title:String?,url:String?) {
        self.description = description
        self.id = id
        self.thumb = thumb
        self.title = title
        self.url = url
    }
}
