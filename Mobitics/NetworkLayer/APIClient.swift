//
//  APIClient.swift
//  Mobitics
//
//  Created by Jagan on 26/12/19.
//  Copyright © 2019 Jagan. All rights reserved.
//

import UIKit

class APIClient: NSObject {

    //MARK:- Get API call method
   enum Result<T> {
       case Success(T)
       case Error(String)
   }
    
    func getDataWith(completion: @escaping (Result<[[String: AnyObject]]>) -> Void) {
            
            let urlString = "https://interview-e18de.firebaseio.com/media.json?print=pretty"
            
            guard let url = URL(string: urlString) else { return completion(.Error("Invalid URL, we can't update your feed")) }

            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
             guard error == nil else { return completion(.Error(error!.localizedDescription)) }
                guard let data = data else { return completion(.Error(error?.localizedDescription ?? "There are no new Items to show"))
    }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [[String: AnyObject]] {
                        
                        DispatchQueue.main.async {
                            completion(.Success(json))
                        }
                    }
                } catch let error {
                    return completion(.Error(error.localizedDescription))
                }
                }.resume()
        }
}

