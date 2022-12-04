/// Determines which types of nodes the plugin supports
enum NodeType {
  localGLTF2, //0. Node with renderable with fileending .gltf in the Flutter asset folder
  localGBL, //1. Node with renderable with fileending .gbl in the Flutter asset folder
  webGLB, //2. Node with renderable with fileending .glb loaded from the internet during runtime
  fileSystemAppFolderGLB, //3. Node with renderable with fileending .glb in the documents folder of the current app
  fileSystemAppFolderGLTF2, //4. Node with renderable with fileending .gltf in the documents folder of the current app
  text, //5. Text node, create view from String on native Platform
  localVideo, //6. Video node, created from flutter assets
  localImage, //7. image node, created from flutter assets
  fileSystemAppFolderImage, //8. image node, created from the app file system
  fileSystemAppFolderVideo, //9. Video node, created from the app file system
  localAudio, //10. audio file from the Flutter asset folder
  fileSystemAppFolderAudio, //11. audio file from the fileSystem
  other
}
