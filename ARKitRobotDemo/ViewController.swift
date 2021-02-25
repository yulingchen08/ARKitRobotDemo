//
//  ViewController.swift
//  ARKitRobotDemo
//
//  Created by Eric Chen 陳鈺翎 on 2021/2/22.
//

import ARKit
import SceneKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet weak var sceneView: ARSCNView!
    private var planes: [ UUID: PlaneNode ] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //show fps and time info statics
        sceneView.showsStatistics = true
        sceneView.delegate = self
        sceneView.debugOptions = [ ARSCNDebugOptions.showFeaturePoints ]
        //set a new scene
//        if let scene = SCNScene(named:"art.scnassets/robot.dae") {
//            sceneView.scene = scene
//        }
        //let scene = SCNScene()
        setGesture()
    }

    func setGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector( addRobot(recognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    /*
     Ray-Casting，类似于Hit-Testing有助于在给定屏幕点的真实曲面上找到三维位置。我找到了raycasting的以下定义：
     光线投射是在真实环境中查找曲面位置的首选方法，但为了兼容性，命中测试函数仍然存在。使用跟踪光线投射，arkit将继续优化结果，以提高使用光线投射放置的虚拟内容的位置精度。
     当用户想要在某个表面上放置虚拟内容时，最好有一个提示。许多ar应用程序都会绘制一个焦点圆或正方形，让用户直观地确认arkit所知道的曲面的形状和对齐方式。因此，要找出在现实世界中的焦点圆或正方形的放置位置，可以使用ARRaycastQuery来询问arkit现实世界中存在的任何曲面的位置。
     下面是一些抽象的示例，您可以在其中看到光线投射方法：
     */
    @objc
    func addRobot(recognizer: UITapGestureRecognizer) {
        print("\(#function) called")
        let tapLocation = recognizer.location(in: sceneView)
       // let hitResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        //guard let hitResult = hitResults.first else { return }
        guard let query = sceneView.raycastQuery(from: tapLocation, allowing: .estimatedPlane, alignment: .any) else {
           return
        }
        let hitResults = sceneView.session.raycast(query)
        guard let hitResult = hitResults.first else {
           print("No surface found")
           return
        }
        guard let scene = SCNScene(named: "art.scnassets/victory.dae") else {
            return
        }
        
        let node = SCNNode()
        for childNode in scene.rootNode.childNodes {
        node.addChildNode(childNode) }
        
        node.pivot = SCNMatrix4MakeTranslation(0.0, 0.0, 0.0)
        //node.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y + 0.20, hitResult.worldTransform.columns.3.z)
        node.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        //reduce the 3D asset to 10% in size
        //node.scale = SCNVector3(0.05, 0.05, 0.05)
        node.scale = SCNVector3(0.001, 0.001, 0.001)
        //rotate 180 along y
        //node.rotation = SCNVector4(0, 1, 0, Float.pi)
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //create a session config
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

}

extension ViewController {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("Surface detected!")
        /*
        if let planeAnchor = anchor as? ARPlaneAnchor {
            //create virtual surface to visualize the detected view
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat (planeAnchor.extent.z))
            plane.materials.first?.diffuse.contents = UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
            // create the node on the surface
            let planeNode = SCNNode(geometry: plane)
            planeNode.position = SCNVector3(planeAnchor.center.x, 0.0, planeAnchor.center.z)
            node.addChildNode(planeNode)
            
        }*/
        
        if let planeAnchor = anchor as? ARPlaneAnchor {
            let planeNode = PlaneNode(anchor: planeAnchor)
        planes[anchor.identifier] = planeNode
        node.addChildNode(planeNode) }
    }
    
    //If find a updated anchor
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, let plane = planes[planeAnchor.identifier] else {
            return
        }
        //to update the virtual plane size and location
        plane.update(anchor: planeAnchor)
    }
    
}
