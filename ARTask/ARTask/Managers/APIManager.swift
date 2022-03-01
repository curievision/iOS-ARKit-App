//
//  APIManager.swift
//  ARTask
//
//  Created by Muzamil Mughal on 8/29/17.
//  Copyright © 2017 Muzamil Mughal. All rights reserved.
//

import Foundation

// This model is used to store downloading progress and downlaoding data
class ARObjectDownloadModel {

    var objectModel: ARObjectModel
    
    init(objectModel: ARObjectModel) {
        self.objectModel = objectModel
    }
    
    // Download service sets these values:
    
    var task: URLSessionDownloadTask?
    var isDownloading = false
    var resumeData: Data?
    
    // Download delegate sets this value:
    
    var progress: Float = 0
}

// This is the response model of the API
class ARObjectModel: Codable {
    var modelId: String = ""
    var format: String = ""
    var key: String = ""
    var mediaId: String = ""
    var url: String = ""
    var thumbnailUrl: String = ""
    var versionId: String = ""
    
    // This property returns the Network Url to dowload the model
    var modelDataUrl: URL {
        get {
            return URL(string: self.url)!
        }
    }
    
    // This property returns the local FilePath Url where the model should be stored after it has been downloaded
    var directoryDestinationUrl: URL {
        return APIManager.shared.localModelFilePathFor(self.modelId)
    }
    
    private enum CodingKeys: String, CodingKey {
        case format
        case key
        case mediaId = "media_id"
        case url
        case thumbnailUrl = "thumbnail_url"
        case versionId = "version_id"
    }
}

class APIManager: NSObject {

    // MARK: - Properties

    static let shared = APIManager()

    // Current Download in progress
    var downloadingModel: ARObjectModel?

    // This property can be used to get the progress of the AR Model
    var updateDownloadingProgressWith: ((_ currentProgress: Float, _ totalSize: Float)->(Void))?
    // This property can be used to listen when the download finishes
    var didFinishedDownloadingModelData: (()->(Void))?

    // This one return a background session used only for downloading
    lazy var downloadSession: URLSession = {
        //    let configuration = URLSessionConfiguration.default
        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        configuration.allowsCellularAccess = true
        configuration.isDiscretionary = false
        configuration.sessionSendsLaunchEvents = true
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    // Get default documents url in local file system
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    // Get the file Url for ARModel in documents directory where the ARModel should be present when downloaded
    func localModelFilePathFor(_ modelId: String) -> URL {
        let directoryPath = documentsPath.appendingPathComponent("ARModels")
        if !FileManager.default.fileExists(atPath: directoryPath.path) {
            do {
                try FileManager.default.createDirectory(atPath: directoryPath.path, withIntermediateDirectories: true, attributes: nil)

            } catch {
                NSLog("Couldn't create document directory")
            }
        }
        return documentsPath.appendingPathComponent("\("ARModels")/\(modelId).usdz")
    }

    var downloadsSession: URLSession!
    
    // All Active downloads in progress
    var activeDownloads: [URL: ARObjectDownloadModel] = [:]

    private override init() {
        super.init()
    }

    // This method gets AR Model info from API given a model ID
    func getModelDataFor(_ id: String, _ completion: @escaping ((ARObjectModel?)-> Void)) {
        
        var request = URLRequest(url: URL(string: "https://dev.api.curie.io/public/products/\(id)/media?formats=usdz")!, timeoutInterval: 20)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("HNRO_3BeVJRxOAHkF1-hNbmpHAQBDa_O", forHTTPHeaderField: "x-curie-api-key")
        
        let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            
            // Check if there's an error or response data is nil
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let response = response else { return }
            guard let data = data else { return }
             
            let statusCode = (response as! HTTPURLResponse).statusCode
            
            // Check the request status code, It must be 200
            
            guard statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Parse the response into local Model and return the model
            
            do {
                
                let decoder = JSONDecoder()
                
                let objectList = try decoder.decode([ARObjectModel].self, from: data)
                DispatchQueue.main.async {
                    completion(objectList.first)
                }
            }
            catch let err {
                print("Err = \(err)")
                completion(nil)
            }

        }
        
        dataTask.resume()
    }
}

extension APIManager {

    // This method downloads the ARModel
    
    func getDataFor(_ model: ARObjectModel) {

        // Check if model is already dowloading
        guard activeDownloads[model.modelDataUrl] == nil else { return }

        self.downloadsSession = self.downloadSession

        var previousDownloadFound = false

        // Check if previous download task is found
        self.downloadsSession.getTasksWithCompletionHandler { (dataTasks, uploadtasks, downloadTasks) in
            for previousTask in downloadTasks {

                // Check if previous download task is found then resume it
                
                if previousTask.originalRequest?.url == model.modelDataUrl {
                    print("Downloaded File size is \(ByteCountFormatter.string(fromByteCount: previousTask.countOfBytesReceived, countStyle: .file))")
                    if previousTask.state == .running {
                        print("Downloading is running")
                    }
                    if previousTask.state == .suspended {
                        print("Downloading is suspended")
                    }

                    if previousTask.state == .completed {
                        print("Downloading is completed")
                    }

                    if previousTask.state == .canceling {
                        print("Downloading is canceling")
                    }
                    previousDownloadFound = true
                    previousTask.resume()
                    let download = ARObjectDownloadModel(objectModel: model)
                    download.task = previousTask
                    download.isDownloading = true
                    self.activeDownloads[download.objectModel.modelDataUrl] = download
                }
                else {
                    // This means that if some other task is going on then suspend it
                    
                    print("Downloaded Cancel File size is \(ByteCountFormatter.string(fromByteCount: previousTask.countOfBytesReceived, countStyle: .file))")
                    if previousTask.state == .running {
                        print("Downloading is running")
                    }
                    if previousTask.state == .suspended {
                        print("Downloading is suspended")
                    }

                    if previousTask.state == .completed {
                        print("Downloading is completed")
                    }

                    if previousTask.state == .canceling {
                        print("Downloading is canceling")
                    }
                    previousTask.suspend()
                }
            }
            
            // If no prevoius download tasks are found then create a new one
            if previousDownloadFound == false {
                createNewDownLoad()
            }
        }

        // This created a new download task
        func createNewDownLoad() {
            let download = ARObjectDownloadModel(objectModel: model)

            var request = URLRequest(url: model.modelDataUrl)
            request.httpMethod = "GET"
            download.task = self.downloadsSession.downloadTask(with: request)
            download.task!.resume()
            download.isDownloading = true
            self.activeDownloads[download.objectModel.modelDataUrl] = download
            self.downloadingModel = model
        }

//        createNewDownLoad()

    }
}

// MARK: - URLSessionDelegate

extension APIManager: URLSessionDelegate {

    // Standard background session handler
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {

            if let completionHandler = AppDelegate.sharedInstance.backgroundSessionCompletionHandler {
                AppDelegate.sharedInstance.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
}

extension APIManager: URLSessionDownloadDelegate {

    // This delegate method lets us know the downlaod task is finished
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        // Check if the task just finished exists in active downloads or not
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        guard let download = self.activeDownloads[sourceURL] else { return }
        self.activeDownloads[sourceURL] = nil
        self.downloadingModel = nil

//        print("DownloadLocation is \(location.path)")
        
        // Save the downloaded AR Model to the desired local filePath where it should be stored
        let destinationURL = localModelFilePathFor(download.objectModel.modelId)
        print(destinationURL)

        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            download.isDownloading = false
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        
        self.downloadingModel = nil
        
        // Inform the listening class that model has been downloaded and saved
        self.didFinishedDownloadingModelData?()
    }

    // This delegate method lets us know the download progress
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {

        guard let url = downloadTask.originalRequest?.url,
            let download = self.activeDownloads[url]  else { return }

        download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)

        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite,
                                                  countStyle: .file)

        let currentProgress = ByteCountFormatter.string(fromByteCount: totalBytesWritten,
                                                        countStyle: .file)
        print("\(currentProgress) done of \(totalSize)")
        self.updateDownloadingProgressWith?(Float(totalBytesWritten), Float(totalBytesExpectedToWrite))
    }

}

