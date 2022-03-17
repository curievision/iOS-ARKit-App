//
//  ViewController.swift
//  ARTask
//
//  Created by Muzamil.Mughal on 22/02/2022.
//

import UIKit
import SceneKit
import SceneKit.ModelIO
import QuickLook
import ARKit
import ARManager

class ViewController: UIViewController {

    // MARK:- Outlets
    
    // This scene viewer renders the 3D object in rotation animation
    @IBOutlet weak var sceneViewer: SCNView!{
        didSet {
            sceneViewer.autoenablesDefaultLighting = true
            sceneViewer.isUserInteractionEnabled = true
        }
    }
    
    @IBOutlet weak var buttonViewInAR: UIButton!
    @IBOutlet weak var imageViewPlaceHolder: UIImageView!
    
    // MARK:- Private Properties
    
    //This ARDataHandler object provides with method to get ARModel Url
    private let aRDataHandler = ARDataHandler()
    
    // This property is the key for model to be downloaded and used, You can can change it to your own
//    private let aRModelKey = "620ff9c89b762319fd4ccdf4"
    private let aRModelKey = "622252af21464bca8e646a4f"
//
    
    private var modelLocalUrl: URL?
    private var modelThumbnail: String?
    
    // MARK:- View Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Required: Provide your API key
        ARFileManager.shared.apiKey = "haTe07l_YFMNluSBR00ENJHLfD3iGqif"   //"HNRO_3BeVJRxOAHkF1-hNbmpHAQBDa_O"
        
        // Optional: Provide the number of models you want to cache. Default value is 3
        ARFileManager.shared.maxNumberOfModelsToCache = 3
        
        // Optional: Request for the thumbnail url of AR Model
        aRDataHandler.getThumbnailUrlForModelId(id: self.aRModelKey) { [weak self] placeHolderUrl, error in
            guard let self = self else { return }
            guard let placeHolder = placeHolderUrl else { return }
            self.modelThumbnail = placeHolder
            self.configureViews()
        }

        // Request for the local file path url of AR Model
        aRDataHandler.getARModelFor(id: self.aRModelKey) { [weak self] url, error in
            guard let self = self else { return }
            guard let url = url else { return }
            self.modelLocalUrl = url
            self.configureViews()
        }
        
        self.configureViews()
    }
    
    // MARK:- Class Methods
    
    func configureViews() {
        
        if let modelThumbnail = modelThumbnail, let thumnailUrl = URL(string: modelThumbnail) {
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: thumnailUrl) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            guard let self = self else { return }
                            self.imageViewPlaceHolder.image = image
                        }
                    }
                }
            }
        }
        
        self.imageViewPlaceHolder.isHidden = modelLocalUrl != nil
        self.buttonViewInAR.isHidden = modelLocalUrl == nil
        
        if let modelUrl = modelLocalUrl {
            
            let mdlAsset = MDLAsset(url: modelUrl)
            mdlAsset.loadTextures()
            let scene = SCNScene(mdlAsset: mdlAsset)
            
            let spin = CABasicAnimation.init(keyPath: "rotation")
            spin.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 20, z: 0, w: 0))
            spin.toValue = NSValue(scnVector4: SCNVector4(x:0, y: 20, z: 0, w: Float(CGFloat(2 * Double.pi))))
            spin.duration = 15
            spin.repeatCount = .infinity
            self.sceneViewer.scene = scene
            self.sceneViewer.scene?.rootNode.addAnimation(spin, forKey: "spin around")
        }
    }
    
    // MARK:- Actions
    
    @IBAction func buttonViewInARTapped(_ sender: Any) {
        self.moveToPreviewView()
    }
    
    @IBAction func clearCachedButtonTapped(_ sender: Any) {
//        ARCacheManager.shared.clearCache()
    }
    
    // MARK:- Navigation
    
    func moveToPreviewView() {
        let previewController = QLPreviewController()
        previewController.dataSource = self
        self.present(previewController, animated: true, completion: nil)
    }
}

extension ViewController: QLPreviewControllerDataSource {

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int { return 1 }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        
        let fileUrl = self.modelLocalUrl ?? URL(fileURLWithPath: "")
        return fileUrl as QLPreviewItem
    }
}
