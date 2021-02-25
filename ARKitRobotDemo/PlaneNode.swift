//
//  PlaneNode.swift
//  ARKitRobotDemo
//
//  Created by Eric Chen 陳鈺翎 on 2021/2/22.
//

import Foundation
import SceneKit
import ARKit

class PlaneNode: SCNNode {
    private var anchor: ARPlaneAnchor!
    private var plane: SCNPlane!
    
    init(anchor: ARPlaneAnchor) {
        super.init()
        self.anchor = anchor
        //create a virtual place to virtualize the detected surface
        self.plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        self.plane.materials.first?.diffuse.contents = UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
        
        
        self.geometry = plane
        self.position = SCNVector3(anchor.center.x, 0.0, anchor.center.z)
                
        //Because of the SceneKit is vertical, rotate it by 90 degree
        self.eulerAngles.x = -Float.pi / 2.0

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(anchor: ARPlaneAnchor) { self.anchor = anchor
        
        plane.width = CGFloat(anchor.extent.x)
        plane.height = CGFloat(anchor.extent.z)
        // update location of plane
        self.position = SCNVector3(anchor.center.x, 0.0, anchor.center.z) }
    
}
