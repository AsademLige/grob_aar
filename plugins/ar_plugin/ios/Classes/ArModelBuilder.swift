import UIKit
import Foundation
import ARKit
import GLTFSceneKit
import Combine
import SamMitiAR

// Responsible for creating Renderables and Nodes
class ArModelBuilder: NSObject {
    let virtualObjectLoader = SamMitiVitualObjectLoader()
    
    var textNodes:Dictionary<String, SCNText> = [:]
    var textNodesColor:Dictionary<String, UIColor> = [:]
    var textNodesBgColor:Dictionary<String, UIColor> = [:]
    var textNodesMaterial:Dictionary<String, SCNMaterial> = [:]
    
    func makePlane(anchor: ARPlaneAnchor, flutterAssetFile: String?) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        //Create material
        let material = SCNMaterial()
        let opacity: CGFloat
        
        if let textureSourcePath = flutterAssetFile {
            // Use given asset as plane texture
            let key = FlutterDartProject.lookupKey(forAsset: textureSourcePath)
            if let image = UIImage(named: key, in: Bundle.main,compatibleWith: nil){
                // Asset was found so we can use it
                material.diffuse.contents = image
                material.diffuse.wrapS = .repeat
                material.diffuse.wrapT = .repeat
                plane.materials = [material]
                opacity = 1.0
            } else {
                // Use standard planes
                opacity = 0.3
            }
        } else {
            // Use standard planes
            opacity = 0.3
        }
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        // rotate plane by 90 degrees to match the anchor (planes are vertical by default)
        planeNode.eulerAngles.x = -.pi / 2

        planeNode.opacity = opacity

        return planeNode
    }

    func updatePlaneNode(planeNode: SCNNode, anchor: ARPlaneAnchor){
        if let plane = planeNode.geometry as? SCNPlane {
            // Update plane dimensions
            plane.width = CGFloat(anchor.extent.x)
            plane.height = CGFloat(anchor.extent.z)
            // Update texture of planes
            let imageSize: Float = 65 // in mm
            let repeatAmount: Float = 1000 / imageSize //how often per meter we need to repeat the image
            if let gridMaterial = plane.materials.first {
                gridMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(anchor.extent.x * repeatAmount, anchor.extent.z * repeatAmount, 1)
            }
        }
       planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    }

    func makeNodeFromGltfGblFileOld(name: String, modelPath: String, transformation: Array<NSNumber>?) -> SCNNode? {
        var scene: SCNScene
        let node: SCNNode = SCNNode()
    
        do {
            let sceneSource = try GLTFSceneSource(path: modelPath)
            scene = try sceneSource.scene()
            for child in scene.rootNode.childNodes {
                child.scale = SCNVector3(0.1,0.1,0.1)
                child.scale = SCNVector3(1,1,1)
                child.light = SCNLight()
                
                child.light?.intensity = 1000
                child.light?.type = SCNLight.LightType.directional
                child.light?.color = UIColor.white
                
                child.castsShadow = false
                child.position = SCNVector3Zero
                
                node.addChildNode(child.clone())
            }
            node.name = name
            if let transform = transformation {
                node.transform = deserializeMatrix4(transform)
            }
            return node
        } catch let error{
            print("\(error.localizedDescription)")
            return nil
        }
    }
    
    func makeNodeFromGltfGblFile(name: String,
                                 modelPath: String,
                                 transformation: Array<NSNumber>?,
                                 light: Bool,
                                 intensity: Int,
                                 type: Int,
                                 isEnabled: Bool) -> SCNNode? {
        let node: SCNNode = SCNNode()
    
        let virtualObject = SamMitiVirtualObject(gltfPath: modelPath, allowedAlignments: [.horizontal])
        
        virtualObjectLoader.loadVirtualObject(virtualObject) { child in
            child.setAnimationForVirtualObjectRemoving { (node, completed) in
                SceneKitAnimator.animateWithDuration(duration: 0.35 / 2,
                                               timingFunction: .easeIn,
                                                   animations: {
                    let transform = SCNMatrix4MakeScale(0.01, 0.01, 0.01)
                    node.contentNode?.transform = transform
                    }, completion: completed)
                }
            
            child.scale = SCNVector3(0.1,0.1,0.1)
            child.scale = SCNVector3(1,1,1)
            
            if (light) {
                child.light = SCNLight()
                child.light?.color = UIColor.white
                child.light?.intensity = CGFloat(intensity)
                
                switch (type) {
                    case 0:
                        child.light?.type = SCNLight.LightType.ambient
                        break
                    case 1:
                        child.light?.type = SCNLight.LightType.directional
                        break
                    case 2:
                        child.light?.type = SCNLight.LightType.omni
                        break
                    case 3:
                        child.light?.type = SCNLight.LightType.probe
                        break
                    case 4:
                        child.light?.type = SCNLight.LightType.spot
                        break
                    case 5:
                        child.light?.type = SCNLight.LightType.area
                        break
                    default:
                        break
                }
            }
            
            child.castsShadow = false
            child.position = SCNVector3Zero
            
            node.addChildNode(child)
                
            
            node.name = name
            if let transform = transformation {
                node.transform = deserializeMatrix4(transform)
            }
        }
        
        if (!isEnabled) {
            node.isHidden = true
        }
        
        return node
    }
    
    func makeNodeFromImage(name: String,
                           modelPath: String,
                           transformation: Array<NSNumber>?,
                           width: Int,
                           height: Int,
                           isEnabled: Bool) -> SCNNode? {
        let node: SCNNode = SCNNode(geometry: SCNPlane(width: 1, height: 1))
        
        let image = UIImage(named: modelPath)
        node.geometry?.firstMaterial?.diffuse.contents = image
        
        node.name = name
        if let transform = transformation {
            node.transform = deserializeMatrix4(transform)
        }
        
        if (!isEnabled) {
            node.isHidden = true
        }
        
        return node
    }
    
    func makeNodeFromText(name: String,
                          text: String,
                          transformation: Array<NSNumber>?,
                          color: String,
                          bgColor: String,
                          width: Int,
                          height: Int,
                          fontSize: Int,
                          fontStyle: Int,
                          textAlign: Int,
                          isEnabled: Bool
    ) -> SCNNode? {
        let node: SCNNode = SCNNode()
        
        let textNode = SCNText(string: text, extrusionDepth: 0)
        let material = SCNMaterial()
        
        var font = UIFont(name: "Gilroy-Regular", size: CGFloat(fontSize))
        
        switch (fontStyle) {
            case 0:
                font = UIFont(name: "Gilroy-Bold", size: CGFloat(fontSize))
                break
            case 1:
                font = UIFont(name: "Gilroy-BoldItalic", size: CGFloat(fontSize))
                break
            case 2:
                font = UIFont(name: "Gilroy-RegularItalic", size: CGFloat(fontSize))
                break
            default:
                break
        }
        
        material.isDoubleSided = true
        material.diffuse.contents = UIColor(hexString: color)
        textNode.font = font
        textNode.flatness = 0.2
        textNode.materials = [material]
        textNode.isWrapped = true
        textNode.truncationMode = CATextLayerTruncationMode.end.rawValue
        
        textNode.containerFrame = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        
        switch (textAlign) {
            case 0:
                textNode.alignmentMode = CATextLayerAlignmentMode.left.rawValue
                break
            case 1:
                textNode.alignmentMode = CATextLayerAlignmentMode.center.rawValue
                break
            case 2:
                textNode.alignmentMode = CATextLayerAlignmentMode.right.rawValue
                break
            default:
                break
        }
        
        textNodes[name] = textNode
        textNodesBgColor[name] = UIColor(hexString: bgColor)
        textNodesColor[name] = UIColor(hexString: color)
        textNodesMaterial[name] = material
        
        node.geometry = textNode
        node.castsShadow = true
        node.name = name
        
        setTextNodeBound(node: node, width: CGFloat(width), height: CGFloat(height), bgColor: nil)
        
        if let transform = transformation {
            node.transform = deserializeMatrix4(transform)
        }
        
        if (!isEnabled) {
            node.isHidden = true
        }
        
        return node
    }
    
    func setTextColor(node: SCNNode, color: String) {
        let material = textNodesMaterial[node.name!]
        let textNode = textNodes[node.name!]
        
        material?.diffuse.contents = UIColor(hexString: color)
        textNode!.materials = [material!]
        
        node.geometry = textNode
    }
    
    func setTextNodeBound(node: SCNNode, width: CGFloat, height: CGFloat, bgColor: String?) {
        node.childNode(withName: "text", recursively: true)?.removeFromParentNode()
        let textNode = textNodes[node.name!]
        
        textNode?.containerFrame = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        node.geometry = textNode
        
        let minVec = node.boundingBox.min
        let maxVec = node.boundingBox.max
        let bound = SCNVector3Make(maxVec.x - minVec.x,
                                   maxVec.y - minVec.y,
                                   maxVec.z - minVec.z);
        
        let plane = SCNPlane(width: CGFloat(bound.x + 10),
                             height: CGFloat(bound.y + 10))
        plane.cornerRadius = 0.2
        
        plane.firstMaterial?.diffuse.contents = bgColor != nil ? UIColor(hexString: bgColor!) : textNodesBgColor[node.name!]
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(CGFloat( minVec.x) + CGFloat(bound.x) / 2 ,
                                        CGFloat( minVec.y) + CGFloat(bound.y) / 2,CGFloat(minVec.z - 0.01))
        
        node.addChildNode(planeNode)
        
        planeNode.name = "text"
    }
    
    // Creates a node form a given glb model path
    func makeNodeFromWebGlb(name: String, modelURL: String, transformation: Array<NSNumber>?) -> Future<SCNNode?, Never> {
        
        return Future {promise in
            var node: SCNNode? = SCNNode()
            
            let handler: (URL?, URLResponse?, Error?) -> Void = {(url: URL?, urlResponse: URLResponse?, error: Error?) -> Void in
                // If response code is not 200, link was invalid, so return
                if ((urlResponse as? HTTPURLResponse)?.statusCode != 200) {
                    print("makeNodeFromWebGltf received non-200 response code")
                    node = nil
                    promise(.success(node))
                } else {
                    guard let fileURL = url else { return }
                    do {
                        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                        let documentsDirectory = paths[0]
                        let targetURL = documentsDirectory.appendingPathComponent(urlResponse!.url!.lastPathComponent)
                        
                        try? FileManager.default.removeItem(at: targetURL) //remove item if it's already there
                        try FileManager.default.copyItem(at: fileURL, to: targetURL)

                        do {
                            let sceneSource = GLTFSceneSource(url: targetURL)
                            let scene = try sceneSource.scene()

                            for child in scene.rootNode.childNodes {
                                child.scale = SCNVector3(0.01,0.01,0.01) // Compensate for the different model dimension definitions in iOS and Android (meters vs. millimeters)
                                //child.eulerAngles.z = -.pi // Compensate for the different model coordinate definitions in iOS and Android
                                //child.eulerAngles.y = -.pi // Compensate for the different model coordinate definitions in iOS and Android
                                node?.addChildNode(child)
                            }

                            node?.name = name
                            if let transform = transformation {
                                node?.transform = deserializeMatrix4(transform)
                            }
                            /*node?.scale = worldScale
                            node?.position = worldPosition
                            node?.worldOrientation = worldRotation*/

                        } catch {
                            print("\(error.localizedDescription)")
                            node = nil
                        }
                        
                        // Delete file to avoid cluttering device storage (at some point, caching can be included)
                        try FileManager.default.removeItem(at: targetURL)
                        
                        promise(.success(node))
                    } catch {
                        node = nil
                        promise(.success(node))
                    }
                }
                
            }
            
    
            let downloadTask = URLSession.shared.downloadTask(with: URL(string: modelURL)!, completionHandler: handler)
            
            downloadTask.resume()
            
        }
        
    }
    
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension String
{
    func replacingLastOccurrenceOfString(_ searchString: String,
            with replacementString: String,
            caseInsensitive: Bool = true) -> String
    {
        let options: String.CompareOptions
        if caseInsensitive {
            options = [.backwards, .caseInsensitive]
        } else {
            options = [.backwards]
        }

        if let range = self.range(of: searchString,
                options: options,
                range: nil,
                locale: nil) {

            return self.replacingCharacters(in: range, with: replacementString)
        }
        return self
    }
}
