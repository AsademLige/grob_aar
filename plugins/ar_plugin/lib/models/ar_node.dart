// The code in this file is adapted from Oleksandr Leuschenko' ARKit Flutter Plugin (https://github.com/olexale/arkit_flutter_plugin)

import 'package:ar_flutter_plugin/datatypes/ios_light_types.dart';
import 'package:ar_flutter_plugin/datatypes/text_node_font_style.dart';
import 'package:ar_flutter_plugin/datatypes/text_node_align.dart';
import 'package:ar_flutter_plugin/utils/color_extension.dart';
import 'package:ar_flutter_plugin/utils/json_converters.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:io';

/// ARNode is the model class for node-tree objects.
/// It encapsulates the position, rotations, and other transforms of a node, which define a coordinate system.
/// The coordinate systems of all the sub-nodes are relative to the one of their parent node.
class ARNode {
  ARNode.model3D({
    required this.type,
    required this.uri,
    String? name,
    Vector3? position,
    Vector3? scale,
    bool? light = true,
    int? intensity,
    IosLightTypes? iosLightType,
    Vector4? rotation,
    Vector3? eulerAngles,
    Matrix4? transformation,
    bool isEnabled = true,
    bool isAnimated = false,
    Map<String, dynamic>? data,
    List<ARNode>? children,
  })  : id = UniqueKey().toString(),
        name = name ?? "",
        children = children ?? [],
        _isEnabled = isEnabled,
        _isAnimated = isAnimated,
        enabledNotifier = ValueNotifier(isEnabled),
        _light = light,
        _intensity = intensity ?? 1,
        _iosLightType = iosLightType,
        intensityNotifier = ValueNotifier(intensity ?? 1),
        lightNotiier = ValueNotifier(light ?? true),
        iosLightTypeNotifier =
            ValueNotifier(iosLightType ?? IosLightTypes.omni),
        animationNotifier = ValueNotifier(isAnimated),
        transformNotifier = ValueNotifier(createTransformMatrix(
            transformation, position, scale, rotation, eulerAngles)),
        data = data ?? {};

  ARNode.imageNode({
    required this.uri,
    NodeType? type,
    int? width,
    int? height,
    String? name,
    Vector3? position,
    Vector3? scale,
    Vector4? rotation,
    Vector3? eulerAngles,
    Matrix4? transformation,
    bool isEnabled = true,
    Map<String, dynamic>? data,
    List<ARNode>? children,
  })  : id = UniqueKey().toString(),
        name = name ?? "",
        type = type ?? NodeType.localImage,
        _width = width,
        _height = height,
        widthNotifier = ValueNotifier(width ?? 0),
        heightNotifier = ValueNotifier(height ?? 0),
        children = children ?? [],
        _isEnabled = isEnabled,
        enabledNotifier = ValueNotifier(isEnabled),
        transformNotifier = ValueNotifier(createTransformMatrix(
            transformation, position, scale, rotation, eulerAngles)),
        data = data ?? {};

  ARNode.mediaNode({
    required this.uri,
    NodeType? type,
    String? name,
    Vector3? position,
    Vector3? scale,
    Vector4? rotation,
    Color? chromakeyColor,
    Vector3? eulerAngles,
    Matrix4? transformation,
    bool isEnabled = true,
    bool loop = true,
    bool isPlaying = true,
    int? volume,
    Map<String, dynamic>? data,
    List<ARNode>? children,
  })  : id = UniqueKey().toString(),
        name = name ?? "",
        type = type ?? NodeType.localVideo,
        children = children ?? [],
        _isEnabled = isEnabled,
        _loop = loop,
        _isPlaying = isPlaying,
        _volume = volume ?? 100,
        playingNotifier = ValueNotifier(isPlaying),
        enabledNotifier = ValueNotifier(isEnabled),
        loopNotifier = ValueNotifier(loop),
        volumeNotifier = ValueNotifier(volume ?? 100),
        chromakeyColor = chromakeyColor,
        transformNotifier = ValueNotifier(createTransformMatrix(
            transformation, position, scale, rotation, eulerAngles)),
        data = data ?? {};

  ARNode.textNode({
    required text,
    String? name,
    Color? color,
    Color? bgColor,
    int? width,
    int? height,
    int? fontSize,
    bool isEnabled = true,
    NodeFontStyle? fontStyle,
    NodeTextAlign? textAlign,
    Vector3? position,
    Vector3? scale,
    Vector4? rotation,
    Vector3? eulerAngles,
    Matrix4? transformation,
    Map<String, dynamic>? data,
    List<ARNode>? children,
  })  : id = UniqueKey().toString(),
        _text = text,
        name = name ?? "",
        _width = width ?? 500,
        _height = height ?? 50,
        widthNotifier = ValueNotifier(width ?? 0),
        heightNotifier = ValueNotifier(height ?? 0),
        type = NodeType.text,
        _isEnabled = isEnabled,
        enabledNotifier = ValueNotifier(isEnabled),
        colorNotifier = ValueNotifier(color ?? const Color(0xffFFFFFF)),
        bgColorNotifier = ValueNotifier(bgColor ?? const Color(0xff000000)),
        fontStyleNotifier = ValueNotifier(fontStyle ?? NodeFontStyle.normal),
        fontSizeNotifier = ValueNotifier(fontSize ?? 14),
        textNotifier = ValueNotifier(text ?? ""),
        textAlignNotifier = ValueNotifier(textAlign ?? NodeTextAlign.left),
        children = children ?? [],
        _fontSize = fontSize ?? 14,
        _fontStyle = fontStyle ?? NodeFontStyle.normal,
        _textAlign = textAlign ?? NodeTextAlign.left,
        _color = color ?? const Color(0xffFFFFFF),
        _bgColor = bgColor ?? const Color(0xff000000),
        transformNotifier = ValueNotifier(createTransformMatrix(transformation,
            position, scale ?? Vector3(0.2, 0.2, 0.2), rotation, eulerAngles)),
        data = data ?? {};

  /// Specifies the receiver's [NodeType]
  NodeType type;

  /// Specifies the path to the 3D model used for the [ARNode]. Depending on the [type], this is either a relative path or an URL to an online asset
  String? uri;

  /// Text for the text node
  String? _text;

  ///Text color of the text node
  Color? _color;

  /// Chromakey color for videoNode
  Color? chromakeyColor;

  ///Text size of the text node
  int? _fontSize;

  ///Only for the text node or the image node
  int? _width;

  ///Only for the text node or the image node
  int? _height;

  ///Volume of mediaNode
  int? _volume;

  ///Text style of the node
  NodeFontStyle? _fontStyle;

  ///Text align on the node
  NodeTextAlign? _textAlign;

  /// Background color of the text node
  Color? _bgColor;

  ///loop setting for video
  bool? _loop;

  ///create light point to the object
  bool? _light;

  IosLightTypes? _iosLightType;

  int? _intensity;

  /// If false the model is created hidden
  bool _isEnabled;

  bool? _isAnimated;

  bool? _isPlaying;

  /// children on this node
  List<ARNode> children;

  ValueNotifier<Matrix4> transformNotifier;
  ValueNotifier<bool> enabledNotifier;
  ValueNotifier<bool>? animationNotifier;
  ValueNotifier<bool>? loopNotifier;
  ValueNotifier<bool>? playingNotifier;
  ValueNotifier<bool>? lightNotiier;
  ValueNotifier<int>? volumeNotifier;
  ValueNotifier<Color>? colorNotifier;
  ValueNotifier<Color>? bgColorNotifier;
  ValueNotifier<NodeFontStyle>? fontStyleNotifier;
  ValueNotifier<NodeTextAlign>? textAlignNotifier;
  ValueNotifier<String>? textNotifier;
  ValueNotifier<int>? widthNotifier;
  ValueNotifier<int>? heightNotifier;
  ValueNotifier<int>? fontSizeNotifier;
  ValueNotifier<int>? intensityNotifier;
  ValueNotifier<IosLightTypes>? iosLightTypeNotifier;

  IosLightTypes get iosLightType {
    return _iosLightType ?? IosLightTypes.omni;
  }

  set iosLightType(IosLightTypes value) {
    if (_iosLightType != value && iosLightTypeNotifier != null) {
      _iosLightType = value;
      iosLightTypeNotifier!.value = value;
    }
  }

  int get intensity {
    return _intensity ?? 1;
  }

  set intensity(int value) {
    if (value != _intensity && intensityNotifier != null) {
      _intensity = value;
      intensityNotifier!.value = value;
    }
  }

  bool get light {
    return _light ?? false;
  }

  set light(bool value) {
    if (value != _light && lightNotiier != null) {
      _light = value;
      lightNotiier!.value = value;
    }
  }

  NodeTextAlign get textAlign {
    return _textAlign ?? NodeTextAlign.left;
  }

  set textAlign(NodeTextAlign value) {
    if (value != _textAlign && textAlignNotifier != null) {
      textAlignNotifier!.value = value;
      _textAlign = value;
    }
  }

  int get fontSize {
    return _fontSize ?? 14;
  }

  set fontSize(int value) {
    if (_fontSize != value && fontSizeNotifier != null) {
      fontSizeNotifier!.value = value;
      _fontSize = value;
    }
  }

  int get width {
    return _width ?? 0;
  }

  set width(int value) {
    if (_width != value && widthNotifier != null) {
      widthNotifier!.value = value;
      _width = value;
    }
  }

  int get height {
    return _height ?? 0;
  }

  set height(int value) {
    if (_height != value && heightNotifier != null) {
      heightNotifier!.value = value;
      _height = value;
    }
  }

  String get text {
    return _text ?? "";
  }

  set text(String value) {
    if (value != _text && textNotifier != null) {
      textNotifier!.value = value;
      _text = value;
    }
  }

  NodeFontStyle get fontStyle {
    return _fontStyle ?? NodeFontStyle.normal;
  }

  set fontStyle(NodeFontStyle value) {
    if (value != _fontStyle && fontStyleNotifier != null) {
      fontStyleNotifier!.value = value;
      _fontStyle = value;
    }
  }

  bool get isEnabled {
    return _isEnabled;
  }

  set isEnabled(bool value) {
    if (value != _isEnabled) {
      enabledNotifier.value = value;
      _isEnabled = value;
    }
  }

  bool get isAnimated {
    return _isAnimated ?? true;
  }

  set isAnimated(bool value) {
    if (value != _isAnimated && animationNotifier != null) {
      animationNotifier!.value = value;
      _isAnimated = value;
    }
  }

  bool get loop {
    return _loop ?? true;
  }

  set loop(bool value) {
    if (value != _loop && loopNotifier != null) {
      loopNotifier!.value = value;
      _loop = value;
    }
  }

  bool get isPlaying {
    return _isPlaying ?? true;
  }

  set isPlaying(bool value) {
    if (value != _isPlaying && playingNotifier != null) {
      playingNotifier!.value = value;
      _isPlaying = value;
    }
  }

  int get volume {
    return _volume ?? 100;
  }

  set volume(int value) {
    if (value != _volume && volumeNotifier != null) {
      volumeNotifier!.value = value;
      _volume = value;
    }
  }

  Color get color {
    return _color ?? Color(0xFFFFFFFF);
  }

  set color(Color value) {
    if (value != _color && colorNotifier != null) {
      colorNotifier!.value = value;
      _color = value;
    }
  }

  Color get bgColor {
    return _bgColor ?? Color(0xFFFFFFFF);
  }

  set bgColor(Color value) {
    if (value != _bgColor && bgColorNotifier != null) {
      bgColorNotifier!.value = value;
      _bgColor = value;
    }
  }

  /// Determines the receiver's transform.
  /// The transform is the combination of the position, rotation and scale defined below.
  /// So when the transform is set, the receiver's position, rotation and scale are changed to match the new transform.
  Matrix4 get transform => transformNotifier.value;

  set transform(Matrix4 matrix) {
    transformNotifier.value = matrix;
  }

  /// Determines the receiver's position.
  Vector3 get position => transform.getTranslation();

  set position(Vector3 value) {
    final old = Matrix4.fromFloat64List(transform.storage);
    final newT = old.clone();
    newT.setTranslation(value);
    transform = newT;
  }

  translateX(double x) {
    Vector3 newPos = position;
    newPos.x = x;
    position = newPos;
  }

  translateY(double y) {
    Vector3 newPos = position;
    newPos.y = y;
    position = newPos;
  }

  translateZ(double z) {
    Vector3 newPos = position;
    newPos.z = z;
    position = newPos;
  }

  /// Determines the receiver's scale.
  Vector3 get scale => transform.matrixScale;

  set scale(Vector3 value) {
    transform =
        Matrix4.compose(position, Quaternion.fromRotation(rotation), value);
  }

  scaleX(double x) {
    Vector3 newScale = scale;
    newScale.x = x;
    scale = newScale;
  }

  scaleY(double y) {
    Vector3 newScale = scale;
    newScale.y = y;
    scale = newScale;
  }

  scaleZ(double z) {
    Vector3 newScale = scale;
    newScale.z = z;
    scale = newScale;
  }

  /// Determines the receiver's rotation.
  Matrix3 get rotation => transform.getRotation();

  set rotation(Matrix3 value) {
    transform =
        Matrix4.compose(position, Quaternion.fromRotation(value), scale);
  }

  set rotationFromQuaternion(Quaternion value) {
    transform = Matrix4.compose(position, value, scale);
  }

  /// Determines the receiver's euler angles.
  /// The order of components in this vector matches the axes of rotation:
  /// 1. Pitch (the x component) is the rotation about the node's x-axis (in radians)
  /// 2. Yaw   (the y component) is the rotation about the node's y-axis (in radians)
  /// 3. Roll  (the z component) is the rotation about the node's z-axis (in radians)
  Vector3 get eulerAngles => transform.matrixEulerAngles;

  set eulerAngles(Vector3 value) {
    final old = Matrix4.fromFloat64List(transform.storage);
    final newT = old.clone();
    newT.matrixEulerAngles = value;
    transform = newT;
  }

  rotateX(double rX) {
    Vector3 newRotate = eulerAngles;
    newRotate.x = rX;
    eulerAngles = newRotate;
  }

  rotateY(double rY) {
    Vector3 newRotate = eulerAngles;
    newRotate.y = rY;
    eulerAngles = newRotate;
  }

  rotateZ(double rZ) {
    Vector3 newRotate = eulerAngles;
    newRotate.z = rZ;
    eulerAngles = newRotate;
  }

  bool isAudio() {
    return (type == NodeType.fileSystemAppFolderAudio ||
        type == NodeType.localAudio);
  }

  bool isVideo() {
    return (type == NodeType.fileSystemAppFolderVideo ||
        type == NodeType.localVideo);
  }

  bool isMedia() {
    return (type == NodeType.fileSystemAppFolderAudio ||
        type == NodeType.localAudio ||
        type == NodeType.fileSystemAppFolderVideo ||
        type == NodeType.localVideo);
  }

  bool isText() {
    return (type == NodeType.text);
  }

  bool isModel() {
    return (type == NodeType.fileSystemAppFolderGLB ||
        type == NodeType.fileSystemAppFolderGLTF2 ||
        type == NodeType.localGBL ||
        type == NodeType.localGLTF2);
  }

  bool isImage() {
    return (type == NodeType.fileSystemAppFolderImage ||
        type == NodeType.localImage);
  }

  /// Determines the name of the receiver.
  /// Will be autogenerated if not defined.
  String id;

  //visible name, may be not unique
  String name;

  /// Holds any data attached to the node, especially useful when uploading serialized nodes to the cloud. This data is not shared with the underlying platform
  Map<String, dynamic>? data;

  static ARNode clone(ARNode node) {
    return ARNode.fromMap(node.toMap());
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'isAnimated': _isAnimated,
        'isEnabled': isEnabled,
        'isPlaying': isPlaying,
        'light': _light,
        'intensity': _intensity,
        'type': type.index,
        'iosLightType': iosLightType.index,
        'uri': uri,
        'loop': _loop,
        'chromakeyColor': chromakeyColor?.toHex(),
        'text': text,
        'width': _width,
        'height': _height,
        'color': _color?.toHex(),
        'backgroundColor': _bgColor?.toHex(),
        'fontStyle': _fontStyle?.index,
        'textAlign': _textAlign?.index,
        'fontSize': _fontSize,
        'volume': volume,
        'children': children.map((arNode) => arNode.toMap()).toList(),
        'scale': VectorConverter().toJson(scale),
        'position': VectorConverter().toJson(position),
        'eulerAngles': VectorConverter().toJson(eulerAngles),
        'transformation':
            MatrixValueNotifierConverter().toJson(transformNotifier),
        'name': id,
        'sceneName': name,
        'data': data,
      }..removeWhere((String k, dynamic v) => v == null);

  static ARNode fromMap(Map<String, dynamic> map) {
    switch (NodeType.values[map["type"]]) {
      case NodeType.text:
        {
          return ARNode.textNode(
              text: map["text"] as String,
              color: HexColor.fromHex(map["color"]),
              bgColor: HexColor.fromHex(map["backgroundColor"]),
              fontSize: map["fontSize"] as int,
              fontStyle: NodeFontStyle.values[map["fontStyle"] as int],
              textAlign: NodeTextAlign.values[
                  map["textAlign"] != null ? map["textAlign"] as int : 0],
              scale: VectorConverter().fromJson(map["scale"] ?? []),
              position: VectorConverter().fromJson(map["position"] ?? []),
              eulerAngles: VectorConverter().fromJson(map["eulerAngles"] ?? []),
              width: (map["width"] ?? 0) as int,
              height: (map["height"] ?? 0) as int,
              name: map["sceneName"] as String,
              isEnabled: (map["isEnabled"] ?? true) as bool,
              // transformation:
              //     const MatrixConverter().fromJson(map["transformation"] ?? []),
              data: Map<String, dynamic>.from(map["data"] ?? {}),
              children: List<Map<String, dynamic>>.from(map["children"] ?? [])
                  .map((node) => ARNode.fromMap(node))
                  .toList());
        }
      case NodeType.localVideo:
      case NodeType.fileSystemAppFolderVideo:
      case NodeType.localAudio:
      case NodeType.fileSystemAppFolderAudio:
        {
          return ARNode.mediaNode(
              type: NodeType.values[map["type"] as int],
              name: map["sceneName"] as String,
              uri: map["uri"] as String,
              scale: VectorConverter().fromJson(map["scale"] ?? []),
              position: VectorConverter().fromJson(map["position"] ?? []),
              eulerAngles: VectorConverter().fromJson(map["eulerAngles"] ?? []),
              chromakeyColor: (map["chromakeyColor"] != null)
                  ? HexColor.fromHex(map["chromakeyColor"])
                  : null,
              loop: true,
              isEnabled: (map["isEnabled"] ?? true) as bool,
              isPlaying: (map["isPlaying"] ?? true) as bool,
              volume: (map["volume"] ?? 100) as int,
              // transformation:
              //     const MatrixConverter().fromJson(map["transformation"] ?? []),
              data: Map<String, dynamic>.from(map["data"] ?? {}),
              children: List<Map<String, dynamic>>.from(map["children"] ?? [])
                  .map((node) => ARNode.fromMap(node))
                  .toList());
        }
      case NodeType.localImage:
      case NodeType.fileSystemAppFolderImage:
        {
          return ARNode.imageNode(
              type: NodeType.values[map["type"] as int],
              uri: (map["uri"] ?? "") as String,
              name: map["sceneName"] as String,
              width: (map["width"] ?? 0) as int,
              height: (map["height"] ?? 0) as int,
              scale: VectorConverter().fromJson(map["scale"] ?? []),
              position: VectorConverter().fromJson(map["position"] ?? []),
              eulerAngles: VectorConverter().fromJson(map["eulerAngles"] ?? []),
              isEnabled: (map["isEnabled"] ?? true) as bool,
              // transformation:
              //     const MatrixConverter().fromJson(map["transformation"] ?? []),
              data: Map<String, dynamic>.from(map["data"] ?? {}),
              children: List<Map<String, dynamic>>.from(map["children"] ?? [])
                  .map((node) => ARNode.fromMap(node))
                  .toList());
        }
      default:
        {
          return ARNode.model3D(
              type: NodeType.values[map["type"] as int],
              uri: map["uri"] as String,
              name: map["sceneName"] as String,
              scale: VectorConverter().fromJson(map["scale"] ?? []),
              position: VectorConverter().fromJson(map["position"] ?? []),
              eulerAngles: VectorConverter().fromJson(map["eulerAngles"] ?? []),
              isEnabled: (map["isEnabled"] ?? true) as bool,
              isAnimated: (map["isAnimated"] ?? true) as bool,
              light: (map["light"] ?? true) as bool,
              intensity: (map["intensity"] ?? 1) as int,
              iosLightType: IosLightTypes.values[
                  map["iosLightType"] != null ? map["iosLightType"] as int : 2],
              // transformation:
              //     const MatrixConverter().fromJson(map["transformation"] ?? []),
              data: Map<String, dynamic>.from(map["data"] ?? {}),
              children: List<Map<String, dynamic>>.from(map["children"] ?? [])
                  .map((node) => ARNode.fromMap(node))
                  .toList());
        }
    }
  }

  static Future<ARNode?> fromUri(String path) async {
    try {
      File file = File(path);
      final dynamic content = jsonDecode(await file.readAsString());
      return ARNode.fromMap(content);
    } catch (e) {
      return null;
    }
  }
}

/// Helper function to create a Matrix4 from either a given matrix or from position, scale and rotation relative to the origin
Matrix4 createTransformMatrix(Matrix4? origin, Vector3? position,
    Vector3? scale, Vector4? rotation, Vector3? eulerAngles) {
  final transform = origin ?? Matrix4.identity();

  if (position != null) {
    transform.setTranslation(position);
  }
  if (rotation != null) {
    transform.rotate(
        Vector3(rotation[0], rotation[1], rotation[2]), rotation[3]);
  }
  if (eulerAngles != null) {
    transform.matrixEulerAngles = eulerAngles;
  } else {
    transform.matrixEulerAngles = Vector3.all(0);
  }
  if (scale != null) {
    transform.scale(scale);
  } else {
    transform.scale(1.0);
  }
  return transform;
}

extension Matrix4Extenstion on Matrix4 {
  Vector3 get matrixScale {
    final scale = Vector3.zero();
    decompose(Vector3.zero(), Quaternion(0, 0, 0, 0), scale);
    return scale;
  }

  Vector3 get matrixEulerAngles {
    final q = Quaternion(0, 0, 0, 0);
    decompose(Vector3.zero(), q, Vector3.zero());

    final t = q.x;
    q.x = q.y;
    q.y = t;

    final angles = Vector3.zero();

    // roll (x-axis rotation)
    final sinrCosp = 2 * (q.w * q.x + q.y * q.z);
    final cosrCosp = 1 - 2 * (q.x * q.x + q.y * q.y);
    angles[0] = math.atan2(sinrCosp, cosrCosp);

    // pitch (y-axis rotation)
    final sinp = 2 * (q.w * q.y - q.z * q.x);
    if (sinp.abs() >= 1) {
      angles[1] =
          _copySign(math.pi / 2, sinp); // use 90 degrees if out of range
    } else {
      angles[1] = math.asin(sinp);
    }
    // yaw (z-axis rotation)
    final sinyCosp = 2 * (q.w * q.z + q.x * q.y);
    final cosyCosp = 1 - 2 * (q.y * q.y + q.z * q.z);
    angles[2] = math.atan2(sinyCosp, cosyCosp);

    return angles;
  }

  set matrixEulerAngles(Vector3 angles) {
    final translation = Vector3.zero();
    final scale = Vector3.zero();
    decompose(translation, Quaternion(0, 0, 0, 0), scale);
    final r = Quaternion.euler(angles[0], angles[1], angles[2]);
    setFromTranslationRotationScale(translation, r, scale);
  }
}

// https://scidart.org/docs/scidart/numdart/copySign.html
double _copySign(double magnitude, double sign) {
  // The highest order bit is going to be zero if the
  // highest order bit of m and s is the same and one otherwise.
  // So (m^s) will be positive if both m and s have the same sign
  // and negative otherwise.
  /*final long m = Double.doubleToRawLongBits(magnitude); // don't care about NaN
  final long s = Double.doubleToRawLongBits(sign);
  if ((m^s) >= 0) {
      return magnitude;
  }
  return -magnitude; // flip sign*/
  if (sign == 0.0 || sign.isNaN || magnitude.sign == sign.sign) {
    return magnitude;
  }
  return -magnitude; // flip sign
}

class MatrixValueNotifierConverter
    implements JsonConverter<ValueNotifier<Matrix4>, List<dynamic>> {
  const MatrixValueNotifierConverter();

  @override
  ValueNotifier<Matrix4> fromJson(List<dynamic> json) {
    return ValueNotifier(Matrix4.fromList(json.cast<double>()));
  }

  @override
  List<dynamic> toJson(ValueNotifier<Matrix4> matrix) {
    final list = List<double>.filled(16, 0.0);
    matrix.value.copyIntoArray(list);
    return list;
  }
}
