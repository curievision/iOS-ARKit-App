//
//  ARDataHandler.swift
//  ARTask
//
//  Created by Muzamil.Mughal on 23/02/2022.
//

import Foundation

class ARDataHandler: NSObject {
    
    // This method will download and return local filePath Url and place Holder Image for the ARModel with given id
    
    func getARModelFor(id: String, completion: @escaping ((_ url: URL, _ placeHolder: String) -> Void)) {
        
        // Get expected filePath Url of the ARModel
        let fileUrl = APIManager.shared.localModelFilePathFor(id)
        
        //Download the model and return the filePath Url
        
        // Get Model Info from the API First
        APIManager.shared.getModelDataFor(id) { model in
            
            guard let model = model else { return }
            
            // This part is critical as we use Model ID as the model name to store in File System
            model.modelId = id
            
            // Configure completion for downloading
            APIManager.shared.didFinishedDownloadingModelData = {
                APIManager.shared.didFinishedDownloadingModelData = nil
                
                // return local fileUrl as we know the file has been downloaded and saved on the local fileUrl
                DispatchQueue.main.async {
                    completion(fileUrl, model.thumbnailUrl)
                }
            }
            
            // Start downloading the AR Model
            APIManager.shared.getDataFor(model)
        }
    }
}
