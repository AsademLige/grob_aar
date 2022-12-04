import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart';

class NodeFactory {
  get arAnchorManager => null;

  static Future addNodeWithAnchor(
      {required ARNode node,
      required Matrix4 worldPos,
      required ARObjectManager arObjectManager,
      required ARAnchorManager arAnchorManager}) async {
    var anchor = ARPlaneAnchor(transformation: worldPos);
    bool? didAddAnchor = await arAnchorManager.addAnchor(anchor);
    if (didAddAnchor!) {
      await arObjectManager.addNode(node, planeAnchor: anchor);
      return true;
    } else {
      return false;
    }
  }

  static Future addNodeAsChild(
      {required ARNode node,
      required ARPlaneAnchor parent,
      required ARObjectManager arObjectManager}) async {
    await arObjectManager.addNode(node, planeAnchor: parent);
    return true;
  }

  static Future addNode(
      {required ARNode node, required ARObjectManager arObjectManager}) async {
    await arObjectManager.addNode(node);
    return true;
  }

  static ARNode? findNodeByName(ARNode initial, String name) {
    ARNode? node;
    if (initial.name == name) {
      node = initial;
    } else {
      for (var cNode in initial.children) {
        if (cNode.name == name) {
          node = cNode;
        } else {
          node = findNodeByName(cNode, name);
        }
        if (node != null && node.name == name) return node;
      }
    }
    return node;
  }
}
