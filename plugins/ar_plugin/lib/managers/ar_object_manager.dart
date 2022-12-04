import 'package:ar_flutter_plugin/utils/color_extension.dart';
import 'package:ar_flutter_plugin/utils/json_converters.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

// Type definitions to enforce a consistent use of the API
typedef NodeTapResultHandler = void Function(List<String> nodes);
typedef NodeLongTapResultHandler = void Function(List<String> nodes);
typedef NodeDoubleTapResultHandler = void Function(List<String> nodes);
typedef NodePanStartHandler = void Function(String node);
typedef NodePanChangeHandler = void Function(String node);
typedef NodePanEndHandler = void Function(String node, Matrix4 transform);
typedef NodeRotationStartHandler = void Function(String node);
typedef NodeRotationChangeHandler = void Function(String node);
typedef NodeRotationEndHandler = void Function(String node, Matrix4 transform);

/// Manages the all node-related actions of an [ARView]
class ARObjectManager {
  /// Platform channel used for communication from and to [ARObjectManager]
  late MethodChannel _channel;

  /// Debugging status flag. If true, all platform calls are printed. Defaults to false.
  final bool debug;

  /// Lists of nodes on scene
  Map<String, ARNode> _nodes = {};

  /// Callback function that is invoked when the platform detects a tap on a node
  NodeTapResultHandler? onNodeTap;
  NodeLongTapResultHandler? onNodeLongTap;
  NodeDoubleTapResultHandler? onNodeDoubleTap;
  NodePanStartHandler? onPanStart;
  NodePanChangeHandler? onPanChange;
  NodePanEndHandler? onPanEnd;
  NodeRotationStartHandler? onRotationStart;
  NodeRotationChangeHandler? onRotationChange;
  NodeRotationEndHandler? onRotationEnd;

  ARObjectManager(int id, {this.debug = false}) {
    _channel = MethodChannel('arobjects_$id');
    _channel.setMethodCallHandler(_platformCallHandler);
    if (debug) {
      print("ARObjectManager initialized");
    }
  }

  Future<void> _platformCallHandler(MethodCall call) {
    if (debug) {
      print('_platformCallHandler call ${call.method} ${call.arguments}');
    }
    try {
      switch (call.method) {
        case 'onError':
          print(call.arguments);
          break;
        case 'onNodeTap':
          if (onNodeTap != null) {
            final tappedNodes = call.arguments as List<dynamic>;
            onNodeTap!(tappedNodes
                .map((tappedNode) => tappedNode.toString())
                .toList());
          }
          break;
        case 'onNodeLongTap':
          if (onNodeLongTap != null) {
            final tappedNodes = call.arguments as List<dynamic>;
            onNodeLongTap!(tappedNodes
                .map((tappedNode) => tappedNode.toString())
                .toList());
          }
          break;
        case 'onNodeDoubleTap':
          if (onNodeDoubleTap != null) {
            final tappedNodes = call.arguments as List<dynamic>;
            onNodeDoubleTap!(tappedNodes
                .map((tappedNode) => tappedNode.toString())
                .toList());
          }
          break;
        case 'onPanStart':
          if (onPanStart != null) {
            final tappedNode = call.arguments as String;
            // Notify callback
            onPanStart!(tappedNode);
          }
          break;
        case 'onPanChange':
          if (onPanChange != null) {
            final tappedNode = call.arguments as String;
            // Notify callback
            onPanChange!(tappedNode);
          }
          break;
        case 'onPanEnd':
          if (onPanEnd != null) {
            final tappedNodeName = call.arguments["name"] as String;
            final transform =
                MatrixConverter().fromJson(call.arguments['transform'] as List);

            // Notify callback
            onPanEnd!(tappedNodeName, transform);
          }
          break;
        case 'onRotationStart':
          if (onRotationStart != null) {
            final tappedNode = call.arguments as String;
            onRotationStart!(tappedNode);
          }
          break;
        case 'onRotationChange':
          if (onRotationChange != null) {
            final tappedNode = call.arguments as String;
            onRotationChange!(tappedNode);
          }
          break;
        case 'onRotationEnd':
          if (onRotationEnd != null) {
            final tappedNodeName = call.arguments["name"] as String;
            final transform =
                MatrixConverter().fromJson(call.arguments['transform'] as List);

            // Notify callback
            onRotationEnd!(tappedNodeName, transform);
          }
          break;
        default:
          if (debug) {
            print('Unimplemented method ${call.method} ');
          }
      }
    } catch (e) {
      print('Error caught: ' + e.toString());
    }
    return Future.value();
  }

  /// Sets up the AR Object Manager
  onInitialize() {
    _channel.invokeMethod<void>('init', {});
  }

  ARNode checkUniqueIds(ARNode initial) {
    getNodes().forEach((key, cNode) {
      if (initial.id == cNode.id) {
        initial.id = UniqueKey().toString();
      }
    });

    for (var i = 0; i < initial.children.length; i++) {
      initial.children[i] = checkUniqueIds(initial.children[i]);
    }
    return initial;
  }

  /// Add given node to the given anchor of the underlying AR scene (or to its top-level if no anchor is given) and listen to any changes made to its transformation
  Future<bool?> addNode(ARNode node, {ARPlaneAnchor? planeAnchor}) async {
    node = checkUniqueIds(node);
    try {
      _addListeners(node);

      _nodes[node.id] = node;
      if (planeAnchor != null) {
        planeAnchor.childNodes.add(node.id);
        return await _channel.invokeMethod<bool>('addNodeToPlaneAnchor',
            {'node': node.toMap(), 'anchor': planeAnchor.toJson()});
      } else {
        return await _channel.invokeMethod<bool>('addNode', node.toMap());
      }
    } on PlatformException {
      return false;
    }
  }

  _addListeners(ARNode node) {
    node.transformNotifier.addListener(() {
      _channel.invokeMethod<void>('transformationChanged', {
        'name': node.id,
        'transformation':
            MatrixValueNotifierConverter().toJson(node.transformNotifier)
      }).onError((error, stackTrace) => null);
    });

    node.enabledNotifier.addListener(() {
      _channel.invokeListMethod<String>("toggleNode", {
        'name': node.id,
        'value': node.enabledNotifier.value
      }).onError((error, stackTrace) => null);
      ;
    });
    if (node.isModel()) {
      node.animationNotifier?.addListener(() {
        _channel.invokeListMethod<String>("toggleAnimation", {
          'name': node.id,
          'value': node.animationNotifier?.value
        }).onError((error, stackTrace) => null);
      });
    }
    if (node.isMedia()) {
      node.playingNotifier!.addListener(() {
        _channel.invokeListMethod<String>("togglePlayer",
            {'name': node.id, 'value': node.playingNotifier!.value});
      });
      node.volumeNotifier!.addListener(() {
        _channel.invokeListMethod<String>("setVolume", {
          'name': node.id,
          'volume': node.volumeNotifier!.value
        }).onError((error, stackTrace) => null);
      });
    }
    if (node.isModel()) {
      node.lightNotiier!.addListener(() {
        _channel.invokeListMethod<String>("setLight", {
          'name': node.id,
          'light': node.lightNotiier!.value,
          'intensity': node.intensityNotifier!.value,
          'type': node.iosLightTypeNotifier!.value.index
        }).onError((error, stackTrace) => null);
      });
      node.intensityNotifier!.addListener(() {
        _channel.invokeListMethod<String>("setLight", {
          'name': node.id,
          'light': node.lightNotiier!.value,
          'intensity': node.intensityNotifier!.value,
          'type': node.iosLightTypeNotifier!.value.index
        }).onError((error, stackTrace) => null);
      });
      node.iosLightTypeNotifier!.addListener(() {
        _channel.invokeListMethod<String>("setLight", {
          'name': node.id,
          'light': node.lightNotiier!.value,
          'intensity': node.intensityNotifier!.value,
          'type': node.iosLightTypeNotifier!.value.index
        }).onError((error, stackTrace) => null);
      });
    }
    if (node.isText()) {
      node.colorNotifier!.addListener(() {
        _channel.invokeListMethod<String>("setTextColor", {
          'name': node.id,
          'color': node.colorNotifier!.value.toHex()
        }).onError((error, stackTrace) => null);
        ;
      });
      node.bgColorNotifier!.addListener(() {
        if (Platform.isIOS) {
          _channel.invokeMethod<String>('setBounds', {
            'name': node.id,
            'width': node.widthNotifier!.value,
            'height': node.heightNotifier!.value,
            'bgColor': node.bgColorNotifier!.value.toHex(),
          }).onError((error, stackTrace) => null);
        } else {
          _channel.invokeListMethod<String>("setTextBgColor", {
            'name': node.id,
            'bgColor': node.bgColorNotifier!.value.toHex()
          }).onError((error, stackTrace) => null);
        }
      });
      node.fontStyleNotifier!.addListener(() {
        if (Platform.isIOS) {
          _channel.invokeListMethod<String>("setFont", {
            'name': node.id,
            'fontSize': node.fontSizeNotifier!.value,
            'fontStyle': node.fontStyleNotifier!.value.index
          }).onError((error, stackTrace) => null);
          _channel.invokeMethod<String>('setBounds', {
            'name': node.id,
            'width': node.widthNotifier!.value,
            'height': node.heightNotifier!.value,
            'bgColor': node.bgColorNotifier!.value.toHex(),
          }).onError((error, stackTrace) => null);
        } else {
          _channel.invokeListMethod<String>("setTextFontStyle", {
            'name': node.id,
            'fontStyle': node.fontStyleNotifier!.value.index
          }).onError((error, stackTrace) => null);
        }
      });
      node.textAlignNotifier!.addListener(() {
        _channel.invokeListMethod<String>("setTextAlign", {
          'name': node.id,
          'value': node.textAlignNotifier!.value.index
        }).onError((error, stackTrace) => null);
        if (Platform.isIOS) {
          _channel.invokeMethod<String>('setBounds', {
            'name': node.id,
            'width': node.widthNotifier!.value,
            'height': node.heightNotifier!.value,
            'bgColor': node.bgColorNotifier!.value.toHex(),
          }).onError((error, stackTrace) => null);
        }
      });
      node.fontSizeNotifier!.addListener(() {
        if (Platform.isIOS) {
          _channel.invokeListMethod<String>("setFont", {
            'name': node.id,
            'fontSize': node.fontSizeNotifier!.value,
            'fontStyle': node.fontStyleNotifier!.value.index
          }).onError((error, stackTrace) => null);
          _channel.invokeMethod<String>('setBounds', {
            'name': node.id,
            'width': node.widthNotifier!.value,
            'height': node.heightNotifier!.value,
            'bgColor': node.bgColorNotifier!.value.toHex(),
          }).onError((error, stackTrace) => null);
        } else {
          _channel.invokeListMethod<String>("setFontSize", {
            'name': node.id,
            'value': node.fontSizeNotifier!.value
          }).onError((error, stackTrace) => null);
        }
      });
      node.textNotifier!.addListener(() {
        _channel.invokeMethod<String>('setNodeText', {
          'name': node.id,
          'text': node.textNotifier!.value,
        }).onError((error, stackTrace) => null);
      });
    }
    if (node.isText() || node.isImage()) {
      node.widthNotifier!.addListener(() {
        _channel.invokeMethod<String>('setBounds', {
          'name': node.id,
          'width': node.widthNotifier!.value,
          'height': node.heightNotifier!.value,
          'bgColor': node.bgColorNotifier!.value.toHex(),
        }).onError((error, stackTrace) => null);
      });
      node.heightNotifier!.addListener(() {
        _channel.invokeMethod<String>('setBounds', {
          'name': node.id,
          'width': node.widthNotifier!.value,
          'height': node.heightNotifier!.value,
          'bgColor': node.bgColorNotifier!.value.toHex(),
        }).onError((error, stackTrace) => null);
      });
    }

    for (var cNode in node.children) {
      _addListeners(cNode);
    }
  }

  toggleEnabled(String nodeName) {
    if (getNodeById(nodeName) != null) {
      getNodeById(nodeName)!.isEnabled = !getNodeById(nodeName)!.isEnabled;
    }
  }

  toggleAnimation(String nodeName) {
    if (getNodeById(nodeName) != null) {
      getNodeById(nodeName)!.isAnimated = !getNodeById(nodeName)!.isAnimated;
    }
  }

  togglePlaying(String nodeName) {
    if (getNodeById(nodeName) != null) {
      getNodeById(nodeName)!.isPlaying = !getNodeById(nodeName)!.isPlaying;
    }
  }

  Future<bool?> setParent(
      {required ARNode parent, required ARNode child}) async {
    try {
      _removeNode(child);
      if (parent.id == child.id) {
        _nodes[parent.id] = parent;
      } else {
        getNodes()[parent.id]!.children.add(child);
      }

      return await _channel.invokeMethod<bool>(
          "setParent", {'parent': parent.id, 'child': child.id});
    } catch (e) {
      return false;
    }
  }

  ARNode? getParent(ARNode child, {ARNode? initial}) {
    ARNode? parent;

    getNodes().forEach((id, node) {
      for (var cNode in node.children) {
        if (cNode.id == child.id) parent = node;
      }
    });

    return parent;
  }

  /// Remove given node from the AR Scene
  removeNode(ARNode node) {
    setParent(parent: node, child: node);
    _removeNode(node);
    _channel.invokeMethod<String>('removeNode', {'name': node.id});
  }

  _removeNode(ARNode node, {ARNode? initial}) {
    if (initial == null) {
      _nodes.removeWhere((id, cNode) => id == node.id);
      for (var id in _nodes.keys) {
        _removeNode(node, initial: _nodes[id]);
      }
    } else {
      initial.children.removeWhere((cNode) => cNode.id == node.id);
      for (var cNode in initial.children) {
        _removeNode(node, initial: cNode);
      }
    }
  }

  removeAll() {
    getNodes().forEach((name, node) {
      removeNode(node);
    });
    _nodes = {};
  }

  Map<String, ARNode> getNodes({bool includeChildren = true}) {
    if (includeChildren) {
      return Map<String, ARNode>.from(
          _getNodes(_nodes.entries.map((node) => node.value).toList()));
    } else {
      return Map<String, ARNode>.from(_nodes);
    }
  }

  int getNodesCount({ARNode? initial}) {
    int count = 0;
    if (initial == null) {
      return getNodes().length;
    } else {
      count += _getNodes([initial]).length;
    }
    return count;
  }

  Map<String, ARNode> _getNodes(List<ARNode> nodes) {
    Map<String, ARNode> children = {};

    for (var node in nodes) {
      children[node.id] = node;
      children.addAll(_getNodes(node.children));
    }

    return children;
  }

  ARNode? getNodeById(String id) {
    return getNodes()[id];
  }

  ARNode? getNodeByName(String name) {
    try {
      return getNodes()
          .entries
          .singleWhere((node) => node.value.name == name)
          .value;
    } catch (e) {
      return null;
    }
  }
}
