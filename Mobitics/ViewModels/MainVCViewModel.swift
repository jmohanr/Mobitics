//
//  MainVCViewModel.swift
//  Mobitics
//
//  Created by Jagan on 26/12/19.
//  Copyright © 2019 Jagan. All rights reserved.
//

import UIKit

class MainVCViewModel: NSObject {
    @IBOutlet weak var apiClient: APIClient!
    var dataDict = [VideosDataModel]()
    var thumbNailImage = UIImage()

    //MARK:- Fetching data method
    /*
    func fetchingVideoData(completion: @escaping () -> Void){
        APIClient.fetchingVideoData() { (response) -> (Void) in
            if response == true {
                DispatchQueue.main.async {
                    CoreDataModel.retriveData { (json) in
                        self.dataDict = json
                        completion()
                    }
                }
            }
        }
    }
    */
    
    //MARK:- Tableview support Methods
 
   func numberOfItemsToDisplay(in section: Int) -> Int {
    return dataDict.count
   }
    
   func videoTitleToDisplay(for indexPath: IndexPath) -> String {
    return dataDict[indexPath.row].title ?? ""
   }
    func videoId(for indexPath: IndexPath) -> String {
     return dataDict[indexPath.row].id ?? ""
    }
    func videoDescriptionToDisplay(for indexPath: IndexPath) -> String {
    return dataDict[indexPath.row].description ?? ""
    }
    
   func videothumbnailToDisplay(for indexPath: IndexPath) -> UIImage {
    APIClient.downloadedImageFrom(urlString: dataDict[indexPath.row].thumb ?? "") { (image) -> (Void) in
        self.thumbNailImage = image
    }
    return thumbNailImage 
   }
    
    func selectedVideoUrl(for indexPath: IndexPath) -> String {
    return dataDict[indexPath.row].url ?? ""
    }
    
    func totalVideosData(for indexPath: IndexPath)-> [VideosDataModel]{
        var data = dataDict
        data.remove(at: indexPath.row)
        return data
    }
}
