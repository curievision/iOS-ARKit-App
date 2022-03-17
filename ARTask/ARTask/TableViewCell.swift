//
//  TableViewCell.swift
//  ARTask
//
//  Created by Muzamil.Mughal on 23/02/2022.
//

import UIKit
import SceneKit

class TableViewCell: UITableViewCell {

    var viewInARButtonTapped: (() -> Void)?
    
    @IBOutlet weak var sceneViewer: SCNView!{
        didSet {
            sceneViewer.autoenablesDefaultLighting = true
            sceneViewer.isUserInteractionEnabled = true
        }
    }
    
    
    @IBOutlet weak var buttonViewInAR: UIButton!
    @IBOutlet weak var imageViewPlaceHolder: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDataWith(_ scene: SCNScene?) {
        
        self.imageViewPlaceHolder.isHidden = scene != nil
        self.buttonViewInAR.isHidden = scene == nil
        
        if let scene = scene {
            let spin = CABasicAnimation.init(keyPath: "rotation")
            spin.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 20, z: 0, w: 0))
            spin.toValue = NSValue(scnVector4: SCNVector4(x:0, y: 20, z: 0, w: Float(CGFloat(2 * Double.pi))))
            spin.duration = 15
            spin.repeatCount = .infinity
            self.sceneViewer.scene = scene
            self.sceneViewer.scene?.rootNode.addAnimation(spin, forKey: "spin around")
        }
    }
    
    @IBAction func buttonViewInARTapped(_ sender: Any) {
        self.viewInARButtonTapped?()
    }

}
