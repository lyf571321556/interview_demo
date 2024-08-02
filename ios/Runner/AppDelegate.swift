import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private var maskChannel: FlutterMethodChannel?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    initMaskMethodChannel()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    
    fileprivate func initMaskMethodChannel(){
        if let vc = window.rootViewController as? FlutterViewController {
            maskChannel = FlutterMethodChannel(name: "interview_demo/mask_channel", binaryMessenger: vc.binaryMessenger)
            maskChannel?.setMethodCallHandler{ call, result in
                let method=call.method;
                switch(method){
                case MaskMethod.applyMaskToImage.rawValue:
                    DispatchQueue.global(qos: .userInitiated).async {
                        guard let params = call.arguments as? Dictionary<String, AnyObject> else {
                            result(FlutterError(code: "InvaliedParams", message: "Map<*, *>  is required", details:""))
                            return
                        }
                        let originalImagePath = params["originalImagePath"] as! String
                        NSLog("originalImagePath:%@",originalImagePath)
                        let maskImagePath = params["maskImagePath"] as! String
                        NSLog("maskImagePath:%@",maskImagePath)
                        if( originalImagePath.isEmpty || maskImagePath.isEmpty){
                            result(FlutterError(code:"InvaliedParams", message:"originalImagePath and maskImagePath is required",details: ""))
                            return
                        }
                        let application = UIApplication.shared
                        let maskedImagePath = (application.delegate as! AppDelegate).applyMaskImgToOriginalImg(originalImagePath, maskImagePath)
                        NSLog("maskedImagePath:%@",maskedImagePath!)
                        result(maskedImagePath)
                    }
                    break;
                default:
                    result(FlutterMethodNotImplemented);
                    break
                }
                
            }
        }
    }
    
    fileprivate func applyMaskImgToOriginalImg(_ originalImagePath: String,_ maskImagePath: String) -> String?{
        let vc = window.rootViewController as! FlutterViewController
        let originalImagePathKey = vc.lookupKey(forAsset: originalImagePath)
        NSLog("originalImagePathKey:%@",originalImagePathKey)
        let originalImageRealPath = Bundle.main.path(forResource: originalImagePathKey, ofType: nil)
        NSLog("originalImageRealPath:%@",originalImageRealPath!)
        
        guard let originalImage = UIImage(contentsOfFile: originalImageRealPath!) else {
            return nil
        }
        
        
        let maskImagePathKey = vc.lookupKey(forAsset: maskImagePath)
        NSLog("maskImagePathKey:%@",maskImagePathKey)
        let maskImageRealPath = Bundle.main.path(forResource: maskImagePathKey, ofType: nil)
        NSLog("maskImageRealPath:%@",maskImageRealPath!)
        
        guard let maskImage = UIImage(contentsOfFile: maskImageRealPath!) else {
            return nil
        }
        
        
        guard originalImage.size == maskImage.size else {
            return nil
        }
    
        UIGraphicsBeginImageContextWithOptions(originalImage.size, false, originalImage.scale)
        
        guard let originalCGImage = originalImage.cgImage, let maskCGImage = maskImage.cgImage else {
            return nil
        }
        
        let width = Int(maskImage.size.width)
        let height = Int(maskImage.size.height)
        
        let maskImagePixelBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * 4)
        let originalImagePixelBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * 4)
         defer {
             maskImagePixelBuffer.deallocate()
             originalImagePixelBuffer.deallocate()
         }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        let maskImageContext = CGContext(data: maskImagePixelBuffer, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        maskImageContext?.draw(maskCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let originalImageContext = CGContext(data: originalImagePixelBuffer, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        originalImageContext?.draw(originalCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let outputData = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * 4)
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelOffset = (y * width + x) * bytesPerPixel
                let red = maskImagePixelBuffer[pixelOffset + 0]
                let green = maskImagePixelBuffer[pixelOffset + 1]
                let blue = maskImagePixelBuffer[pixelOffset + 2]
                let alpha = maskImagePixelBuffer[pixelOffset + 3]
                if(alpha==255 && red==255 && green==255 && blue==255){
                    outputData[pixelOffset] = originalImagePixelBuffer[pixelOffset]
                    outputData[pixelOffset + 1] = originalImagePixelBuffer[pixelOffset + 1]
                    outputData[pixelOffset + 2] = originalImagePixelBuffer[pixelOffset + 2]
                    outputData[pixelOffset + 3] = originalImagePixelBuffer[pixelOffset + 3]
                }else{
                    outputData[pixelOffset] = 0
                    outputData[pixelOffset + 1] = 0
                    outputData[pixelOffset + 2] = 0
                    outputData[pixelOffset + 3] = 0
                }
            }
        }
        
        let outputDataProvider = CGDataProvider(data: NSData(bytes: outputData, length: width * height * 4))
        let outputCGImage = CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bytesPerPixel * 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue), provider: outputDataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)!

        let processedImage =  UIImage(cgImage: outputCGImage)
        UIGraphicsEndImageContext()
        
        guard let saveFilePath = processedImage.saveImageToFile(fileName: originalImagePath.hash.description) else {
            return nil
        }
        
        return saveFilePath
    }
}

enum MaskMethod: String {
    case applyMaskToImage = "applyMaskToImage";
}

extension CGImage {
    func color(at point: CGPoint) -> UIColor {
        let width = self.width
        let height = self.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var pixelData: [UInt8] = [0, 0, 0, 0]
        let context = CGContext(data: &pixelData,
                                width: 1,
                                height: 1,
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
        context?.draw(self, in: CGRect(x: -point.x, y: -point.y, width: CGFloat(width), height: CGFloat(height)))
        
        let red = CGFloat(pixelData[0]) / 255.0
        let green = CGFloat(pixelData[1]) / 255.0
        let blue = CGFloat(pixelData[2]) / 255.0
        let alpha = CGFloat(pixelData[3]) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

}

extension UIImage {
    func saveImageToFile(fileName: String) -> String? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let filePath = documentsDirectory.appendingPathComponent(fileName)
     
        guard let pngData = self.pngData() else { return nil }
     
        do {
            try pngData.write(to: filePath)
            return filePath.path
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
