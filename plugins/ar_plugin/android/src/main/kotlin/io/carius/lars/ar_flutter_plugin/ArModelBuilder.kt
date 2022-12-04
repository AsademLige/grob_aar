package io.carius.lars.ar_flutter_plugin

import kotlinx.android.synthetic.main.text_view.*

import android.app.Activity
import android.content.Context
import com.google.ar.sceneform.Node
import com.google.ar.sceneform.math.Vector3
import com.google.ar.sceneform.math.Quaternion

import android.widget.TextView
import android.util.TypedValue
import android.widget.ImageView
import android.widget.VideoView
import android.graphics.Typeface
import android.widget.LinearLayout
import android.graphics.drawable.Drawable
import android.view.ViewGroup.LayoutParams
import android.util.Log
import android.media.AudioManager
import android.view.View

import java.util.concurrent.CompletableFuture
import com.google.ar.sceneform.utilities.Preconditions
import com.google.ar.sceneform.math.MathHelper
import com.google.ar.sceneform.ArSceneView
import com.google.ar.sceneform.animation.*
import com.google.ar.sceneform.rendering.*
import com.google.ar.sceneform.FrameTime
import com.google.ar.sceneform.rendering.Color
import android.graphics.Color as GColor
import com.google.ar.sceneform.ux.*
import android.view.Gravity
import android.widget.Toast
import com.google.ar.core.*
import android.net.Uri
import android.media.MediaPlayer
import android.media.AudioAttributes

import io.carius.lars.ar_flutter_plugin.Serialization.*

import io.flutter.FlutterInjector
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.AccessController
import java.io.InputStream
import java.io.FileInputStream

// Responsible for creating Renderables and Nodes
class ArModelBuilder {
    
    public var modelRenderables: MutableMap<String?, ModelRenderable?> = mutableMapOf()
    public var textRenderables: MutableMap<String?, ViewRenderable?> = mutableMapOf()
    public var mediaPlayers: MutableMap<String?, MediaPlayer?> = mutableMapOf()

    // Creates feature point node
    fun makeFeaturePointNode(context: Context, xPos: Float, yPos: Float, zPos: Float): Node {
        val featurePoint = Node()                 
        var cubeRenderable: ModelRenderable? = null      
        MaterialFactory.makeOpaqueWithColor(context, Color(android.graphics.Color.YELLOW))
        .thenAccept { material ->
            val vector3 = Vector3(0.01f, 0.01f, 0.01f)
            cubeRenderable = ShapeFactory.makeCube(vector3, Vector3(xPos, yPos, zPos), material)
            cubeRenderable?.isShadowCaster = false
            cubeRenderable?.isShadowReceiver = false
        }
        featurePoint.renderable = cubeRenderable

        return featurePoint
    }

    // Creates a coordinate system model at the world origin (X-axis: red, Y-axis: green, Z-axis:blue)
    // The code for this function is adapted from Alexander's stackoverflow answer (https://stackoverflow.com/questions/48908358/arcore-how-to-display-world-origin-or-axes-in-debug-mode) 
    fun makeWorldOriginNode(context: Context): Node {
        val axisSize = 0.1f
        val axisRadius = 0.005f

        val rootNode = Node()
        val xNode = Node()
        val yNode = Node()
        val zNode = Node()

        rootNode.addChild(xNode)
        rootNode.addChild(yNode)
        rootNode.addChild(zNode)

        xNode.worldPosition = Vector3(axisSize / 2, 0f, 0f)
        xNode.worldRotation = Quaternion.axisAngle(Vector3(0f, 0f, 1f), 90f)

        yNode.worldPosition = Vector3(0f, axisSize / 2, 0f)

        zNode.worldPosition = Vector3(0f, 0f, axisSize / 2)
        zNode.worldRotation = Quaternion.axisAngle(Vector3(1f, 0f, 0f), 90f)

        MaterialFactory.makeOpaqueWithColor(context, Color(255f, 0f, 0f))
                .thenAccept { redMat ->
                    xNode.renderable = ShapeFactory.makeCylinder(axisRadius, axisSize, Vector3.zero(), redMat)
                }

        MaterialFactory.makeOpaqueWithColor(context, Color(0f, 255f, 0f))
                .thenAccept { greenMat ->
                    yNode.renderable = ShapeFactory.makeCylinder(axisRadius, axisSize, Vector3.zero(), greenMat)
                }

        MaterialFactory.makeOpaqueWithColor(context, Color(0f, 0f, 255f))
                .thenAccept { blueMat ->
                    zNode.renderable = ShapeFactory.makeCylinder(axisRadius, axisSize, Vector3.zero(), blueMat)
                }

        return rootNode
    }

    // Creates a node form a given gltf model path or URL. The gltf asset loading in Scenform is asynchronous, so the function returns a completable future of type Node
    fun makeNodeFromGltf(context: Context, 
                        transformationSystem: TransformationSystem, 
                        objectManagerChannel: MethodChannel, 
                        enablePans: Boolean, 
                        enableRotation: Boolean, 
                        name: String, 
                        modelPath: String, 
                        transformation: ArrayList<Double>,
                        isEnabled: Boolean,
                        isAnimated: Boolean): CompletableFuture<CustomTransformableNode> {
        val completableFutureNode: CompletableFuture<CustomTransformableNode> = CompletableFuture()

        val gltfNode = CustomTransformableNode(transformationSystem, objectManagerChannel, enablePans, enableRotation)

        val light: Light = Light.builder(Light.Type.POINT)
            .setColor(Color(android.graphics.Color.WHITE))
            .setShadowCastingEnabled(false)
            .build();
        light.setIntensity(10000f)
        light.setFalloffRadius(1000f)

        ModelRenderable.builder()
                .setSource(context, Uri.parse(modelPath))
                .setIsFilamentGltf(true)
                .setAsyncLoadEnabled(true)
                .build()
                .thenAccept{ renderable ->
                    modelRenderables.put(name, renderable)
                    
                    if (isAnimated) {
                        gltfNode.setRenderable(renderable).animate(true).start()
                    } else {
                        gltfNode.setRenderable(renderable)
                    } 
                    
                    gltfNode.setEnabled(isEnabled)  

                    gltfNode.name = name
                    val transform = deserializeMatrix4(transformation)
                    gltfNode.worldScale = transform.first
                    gltfNode.worldPosition = transform.second
                    gltfNode.worldRotation = transform.third

                    gltfNode.setLight(light)

                    completableFutureNode.complete(gltfNode)
                }
                .exceptionally { throwable ->
                    completableFutureNode.completeExceptionally(throwable)
                    null // return null because java expects void return (in java, void has no instance, whereas in Kotlin, this closure returns a Unit which has one instance)
                }

    return completableFutureNode
    }

    // Creates a node form a given glb model path or URL. The gltf asset loading in Sceneform is asynchronous, so the function returns a compleatable future of type Node
    fun makeNodeFromGlb(context: Context, 
                        transformationSystem: TransformationSystem, 
                        objectManagerChannel: MethodChannel, 
                        enablePans: Boolean, 
                        enableRotation: Boolean, 
                        name: String, 
                        modelPath: String, 
                        transformation: ArrayList<Double>,
                        isEnabled: Boolean,
                        isAnimated: Boolean): CompletableFuture<CustomTransformableNode> {
        val completableFutureNode: CompletableFuture<CustomTransformableNode> = CompletableFuture()

        val glbNode = CustomTransformableNode(transformationSystem, objectManagerChannel, enablePans, enableRotation)

        val light: Light = Light.builder(Light.Type.POINT)
            .setColor(Color(android.graphics.Color.WHITE))
            .setShadowCastingEnabled(false)
            .build();
        light.setIntensity(100000f)
        light.setFalloffRadius(10000f)

        ModelRenderable.builder()
                .setSource(context, Uri.parse(modelPath))
                .setIsFilamentGltf(true)
                .setAsyncLoadEnabled(true)
                .build()
                .thenAccept{ renderable ->
                    modelRenderables.put(name, renderable)

                    if (isAnimated) {
                        glbNode.setRenderable(renderable).animate(true).start()
                    } else {
                        glbNode.setRenderable(renderable)
                    }

                    glbNode.setEnabled(isEnabled)

                    glbNode.name = name
                    val transform = deserializeMatrix4(transformation)
                    glbNode.worldScale = transform.first
                    glbNode.worldPosition = transform.second
                    glbNode.worldRotation = transform.third

                    glbNode.setLight(light)

                    completableFutureNode.complete(glbNode)
                }
                .exceptionally{throwable ->
                    completableFutureNode.completeExceptionally(throwable)
                    null // return null because java expects void return (in java, void has no instance, whereas in Kotlin, this closure returns a Unit which has one instance)
                }

        return completableFutureNode
    }

    //Creates a node form videoFlutterAsset
    fun makeNodeFromMedia(context: Context, 
                        transformationSystem: TransformationSystem, 
                        objectManagerChannel: MethodChannel, 
                        enablePans: Boolean, 
                        enableRotation: Boolean, 
                        name: String, 
                        videoPath: String, 
                        transformation: ArrayList<Double>,
                        isEnabled: Boolean,
                        color: String,
                        loop: Boolean,
                        type: Int,
                        isPlaying: Boolean,
                        volume: Int): CompletableFuture<CustomTransformableNode> {
        val completableFutureNode: CompletableFuture<CustomTransformableNode> = CompletableFuture()
        val node = CustomTransformableNode(transformationSystem, objectManagerChannel, enablePans, enableRotation)

        var chromaKeyColor: Color = Color(1f, 1f, 1f)

        if (color != "") {
            val gColor = GColor.parseColor(color);

            chromaKeyColor = Color(
                GColor.red(gColor).toFloat(), 
                GColor.green(gColor).toFloat(), 
                GColor.blue(gColor).toFloat())
        }

        if (type == 9 || type == 11) {
            val player: MediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setContentType(AudioAttributes.CONTENT_TYPE_MOVIE)
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .build()
                )
                setDataSource(context, Uri.parse(videoPath))
                setAudioStreamType(AudioManager.STREAM_NOTIFICATION)
                setLooping(loop)
                prepare()
            }
            mediaPlayers.put(name, player)
    
            val videoNode = VideoNode(context, player, if (color != "") chromaKeyColor else null, null)
            videoNode.setParent(node)
            player.start()
            player.setVolume(volume.toFloat() / 100, volume.toFloat() / 100)
            if (!isPlaying) {
                player.pause()
            }
        } else {
            context.assets.openFd(videoPath).also {
                val player: MediaPlayer = MediaPlayer().apply {
                    setAudioAttributes(
                        AudioAttributes.Builder()
                            .setContentType(AudioAttributes.CONTENT_TYPE_MOVIE)
                            .setUsage(AudioAttributes.USAGE_MEDIA)
                            .build()
                    )
                    setDataSource(it.fileDescriptor, it.startOffset, it.declaredLength)
                    setAudioStreamType(AudioManager.STREAM_NOTIFICATION);
                    setLooping(loop)
                    prepare()
                }
                mediaPlayers.put(name, player)
                
                if (type != 10 && type != 11) {
                    val videoNode = VideoNode(context, player, if (color != "") chromaKeyColor else null, null)
                    videoNode.setParent(node)
                }
                player.start()
                player.setVolume(volume.toFloat() / 100, volume.toFloat() / 100)
                if (!isPlaying) {
                    player.pause()
                }
            }.close()
        }

        node.name = name
        if (type != 10 && type != 11) {
            node.setEnabled(isEnabled)
        } else {
            node.setEnabled(false)
        }
        val transform = deserializeMatrix4(transformation)
        node.worldScale = transform.first
        node.worldPosition = transform.second
        node.worldRotation = transform.third
        completableFutureNode.complete(node)

        return completableFutureNode
    }

    fun makeNodeFromImage(context: Context, 
                        transformationSystem: TransformationSystem, 
                        objectManagerChannel: MethodChannel, 
                        enablePans: Boolean, 
                        enableRotation: Boolean, 
                        name: String, 
                        assetPath: String, 
                        transformation: ArrayList<Double>,
                        isEnabled: Boolean,  
                        textViewWidth: Int,
                        textViewHeight: Int,
                        type: Int): CompletableFuture<CustomTransformableNode> {
        val completableFutureNode: CompletableFuture<CustomTransformableNode> = CompletableFuture()

        val imageNode = CustomTransformableNode(transformationSystem, objectManagerChannel, enablePans, enableRotation)

        val image = ImageView(context)
        
        if (type == 7) {
            context.assets.open(assetPath).also{
                image.setImageDrawable(Drawable.createFromStream(it, null))
            }.close()
        } else {
            image.setImageURI(Uri.parse(assetPath))    
        }

        ViewRenderable.builder()
            .setView(context, image)
            .build()
                .thenAccept{ renderable ->
                    textRenderables.put(name, renderable)
                    imageNode.renderable = renderable

                    imageNode.setEnabled(isEnabled)
                    imageNode.name = name
                    val transform = deserializeMatrix4(transformation)
                    imageNode.worldScale = transform.first
                    imageNode.worldPosition = transform.second
                    imageNode.worldRotation = transform.third
                    completableFutureNode.complete(imageNode)
                }
                .exceptionally { throwable ->
                    completableFutureNode.completeExceptionally(throwable)
                    null // return null because java expects void return (in java, void has no instance, whereas in Kotlin, this closure returns a Unit which has one instance)
                }

    return completableFutureNode
    }

    fun makeNodeFromText(context: Context, 
                        transformationSystem: TransformationSystem, 
                        objectManagerChannel: MethodChannel, 
                        enablePans: Boolean, 
                        enableRotation: Boolean, 
                        name: String, 
                        text: String, 
                        transformation: ArrayList<Double>, 
                        color: String, 
                        backgroundColor: String, 
                        fontSize: Int, 
                        fontStyle: Int, 
                        textAlign: Int, 
                        textViewWidth: Int,
                        textViewHeight: Int,
                        isEnabled: Boolean): CompletableFuture<CustomTransformableNode> {
        val completableFutureNode: CompletableFuture<CustomTransformableNode> = CompletableFuture()

        val textNode = CustomTransformableNode(transformationSystem, objectManagerChannel, enablePans, enableRotation)

        val normal = Typeface.createFromAsset(context.getAssets(), "fonts/Gilroy-Regular.ttf");
        val bold = Typeface.createFromAsset(context.getAssets(), "fonts/Gilroy-Bold.ttf");
        val italic = Typeface.createFromAsset(context.getAssets(), "fonts/Gilroy-BoldItalic.ttf");
        val italicBold = Typeface.createFromAsset(context.getAssets(), "fonts/Gilroy-BoldItalic.ttf");
        
        var view = R.layout.text_view;

        ViewRenderable.builder()
            .setView(context, view)
            .build()
                .thenAccept{ renderable ->
                    textRenderables.put(name, renderable)
                    val textView: TextView = renderable.getView() as TextView
                    textView.text = text
                    textView.setTextColor(GColor.parseColor(color))
                    textView.setBackgroundColor(GColor.parseColor(backgroundColor))
                    textView.setTextSize(TypedValue.COMPLEX_UNIT_PT, fontSize.toFloat())

                    when (fontStyle) {
                        0 -> {
                            textView.setTypeface(bold!!)
                        }
                        1 -> {
                            textView.setTypeface(italicBold!!)
                        }
                        2 -> {
                            textView.setTypeface(italic!!)
                        }
                        3 -> {
                            textView.setTypeface(normal!!)
                        }
                    }

                    when (textAlign) {
                        0 -> {
                            textView.setGravity(Gravity.START)
                            textView.textAlignment = View.TEXT_ALIGNMENT_VIEW_START
                        }
                        1 -> {
                            textView.setGravity(Gravity.CENTER)
                            textView.textAlignment = View.TEXT_ALIGNMENT_CENTER
                        }
                        2 -> {
                            textView.setGravity(Gravity.END)
                            textView.textAlignment = View.TEXT_ALIGNMENT_VIEW_END
                        }
                    }

                    textViewWidth?.let {
                        textView.layoutParams = textView.layoutParams.apply {
                            if (textViewWidth == 0) {
                                width = LayoutParams.MATCH_PARENT
                            } else {
                                width = textViewWidth
                            }
                        }
                    }

                    textViewHeight?.let {
                        textView.layoutParams = textView.layoutParams.apply {
                            if (textViewHeight == 0) {
                                height = LayoutParams.MATCH_PARENT
                            } else {
                                height = textViewHeight
                            }
                        }
                    }
                    
                    textNode.renderable = renderable

                    textNode.setEnabled(isEnabled)
                    textNode.name = name
                    val transform = deserializeMatrix4(transformation)
                    textNode.worldScale = transform.first
                    textNode.worldPosition = transform.second
                    textNode.worldRotation = transform.third
                    completableFutureNode.complete(textNode)
                }
                .exceptionally { throwable ->
                    completableFutureNode.completeExceptionally(throwable)
                    null // return null because java expects void return (in java, void has no instance, whereas in Kotlin, this closure returns a Unit which has one instance)
                }

    return completableFutureNode
    }
}

class CustomTransformableNode(transformationSystem: TransformationSystem, objectManagerChannel: MethodChannel, enablePans: Boolean, enableRotation: Boolean) :
    TransformableNode(transformationSystem) { //

    private lateinit var customTranslationController: CustomTranslationController

    private lateinit var customRotationController: CustomRotationController

    init {
        // Remove standard controllers
        translationController.isEnabled = false
        rotationController.isEnabled = false
        scaleController.isEnabled = false
        removeTransformationController(translationController)
        removeTransformationController(rotationController)
        removeTransformationController(scaleController)


        // Add custom controllers if needed
        if (enablePans) {
            customTranslationController = CustomTranslationController(
                this,
                transformationSystem.dragRecognizer,
                objectManagerChannel
            )
            addTransformationController(customTranslationController)
        }
        if (enableRotation) {
            customRotationController = CustomRotationController(
                this,
                transformationSystem.twistRecognizer,
                objectManagerChannel
            )
            addTransformationController(customRotationController)
        }
    }
}

class CustomTranslationController(transformableNode: BaseTransformableNode, gestureRecognizer: DragGestureRecognizer, objectManagerChannel: MethodChannel) :
    TranslationController(transformableNode, gestureRecognizer) {

    val platformChannel: MethodChannel = objectManagerChannel

    override fun canStartTransformation(gesture: DragGesture): Boolean {
        platformChannel.invokeMethod("onPanStart", transformableNode.name)
        super.canStartTransformation(gesture)
        return transformableNode.isSelected
    }

    override fun onContinueTransformation(gesture: DragGesture) {
        platformChannel.invokeMethod("onPanChange", transformableNode.name)
        super.onContinueTransformation(gesture)
        }

    override fun onEndTransformation(gesture: DragGesture) {
        val serializedLocalTransformation = serializeLocalTransformation(transformableNode)
        platformChannel.invokeMethod("onPanEnd", serializedLocalTransformation)
        super.onEndTransformation(gesture)
     }
}

class CustomRotationController(transformableNode: BaseTransformableNode, gestureRecognizer: TwistGestureRecognizer, objectManagerChannel: MethodChannel) :
    RotationController(transformableNode, gestureRecognizer) {

    val platformChannel: MethodChannel = objectManagerChannel

    override fun canStartTransformation(gesture: TwistGesture): Boolean {
        platformChannel.invokeMethod("onRotationStart", transformableNode.name)
        super.canStartTransformation(gesture)
        return transformableNode.isSelected
    }

    override fun onContinueTransformation(gesture: TwistGesture) {
        platformChannel.invokeMethod("onRotationChange", transformableNode.name)
        super.onContinueTransformation(gesture)
    }

    override fun onEndTransformation(gesture: TwistGesture) {
        val serializedLocalTransformation = serializeLocalTransformation(transformableNode)
        platformChannel.invokeMethod("onRotationEnd", serializedLocalTransformation)
        super.onEndTransformation(gesture)
     }
}
