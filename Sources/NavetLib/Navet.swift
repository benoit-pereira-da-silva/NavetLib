//
//  Navet.swift
//  navet
//
//  Created by Benoit Pereira da silva on 27/10/2017.
//  Copyright © 2017 Pereira da Silva https://pereira-da-silva.com All rights reserved.
//

import Foundation

#if os(OSX)
    import Cocoa
    import CoreMedia
    import AVFoundation
    import CoreImage

    // Navet isn't a good movie generator.
    // It produces generative "Navets"
    // Navet handle the Exit calls
    public class Navet{

        public enum ColorMode:String {
            case uniform
            case random
            case progressive
        }

        public enum VideoCodec:String{
            case hevc
            case h264
            case jpeg
            case proRes4444
            case proRes422
        }

        public enum FileType:String{
            case mov
            case mp4
            case m4v
        }

        public static let version:String = "1.0.6"

        // MARK : - To be exposed to the command line


        public var width:CGFloat = 1080

        public var height:CGFloat = 720

        public var fps: Double = 25

        public var numberOfSeconds:Double = 10

        public var colorMode:ColorMode = .progressive

        public var videoCodec:VideoCodec = .h264

        public var fileType:FileType = .mov

        public var currentR:CGFloat = 0
        public var currentG:CGFloat = 0
        public var currentB:CGFloat = 0

        public var colorStep:CGFloat = 1 / 32

        public enum ColorComponents {
            case r
            case g
            case b
        }

        public var currentColorComponent:ColorComponents = .r

        // MARK : -

        public lazy var navetFolderURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.desktopDirectory, in: .userDomainMask)[0].appendingPathComponent("navet")

        public lazy var videoFileURL = self.navetFolderURL.appendingPathComponent("\(self.videoCodec.rawValue)-\(self.numberOfSeconds)s-\(self.width)X\(self.height)@\(self.fps)fps.\(self.fileType.rawValue)")

        public func generate(_ progress: @escaping ((Progress) -> Void)){
            let timeScale:CMTimeScale = 44000
            do{
                try FileManager.default.createDirectory(at: self.navetFolderURL, withIntermediateDirectories: true, attributes: nil)
                if FileManager.default.fileExists(atPath: self.videoFileURL.path){
                    try FileManager.default.removeItem(at: self.videoFileURL)
                }
                let videoWriter = try AVAssetWriter(outputURL: self.videoFileURL, fileType: self.type)
                let videoSettings: [String : AnyObject] = [
                    AVVideoCodecKey  : self.codec as AnyObject,
                    AVVideoWidthKey  : width as AnyObject,
                    AVVideoHeightKey : height as AnyObject
                ]

                let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
                let sourceBufferAttributes = [
                    (kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32ARGB),
                    (kCVPixelBufferWidthKey as String): Float(width),
                    (kCVPixelBufferHeightKey as String): Float(height)] as [String : Any]

                let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
                    assetWriterInput: videoWriterInput,
                    sourcePixelBufferAttributes: sourceBufferAttributes
                )

                guard videoWriter.canAdd(videoWriterInput) == true else{
                    print("Input is not compatible \(videoWriterInput)")
                    exit(EX__BASE)
                }

                videoWriter.add(videoWriterInput)

                guard videoWriter.startWriting() == true else{
                    print("\(String(describing: videoWriter.error ))")
                    exit(EX__BASE)
                }

                videoWriter.startSession(atSourceTime: CMTime.zero)
                guard pixelBufferAdaptor.pixelBufferPool != nil else{
                    print("pixelBufferPool is nil")
                    exit(EX__BASE)
                }
                let currentProgress = Progress(totalUnitCount: Int64(self.n))
                let queue = DispatchQueue.main//DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
                videoWriterInput.requestMediaDataWhenReady(on: queue, using: {
                    //let frameDuration = CMTimeMake(1, Int32(self.fps))
                    let frameDuration = CMTime(seconds: Double(1) / Double(self.fps) , preferredTimescale: timeScale)
                    var frameCount:Int64 = 0
                    for i in 0..<self.n{
                        autoreleasepool(invoking: { () -> Void in
                            frameCount = Int64(i)
                            let presentationTime = CMTime(seconds: Double(frameCount) * frameDuration.seconds, preferredTimescale: timeScale)
                            var rect = NSRect(x: 0, y: 0, width: self.width, height: self.height)
                            let tc = presentationTime.timeCodeRepresentation(Double(self.fps), showImageNumber: true)

                            print ("#\(Int(frameCount).paddedInt(numberOfDigit: 5)) \(tc)   \(presentationTime.seconds) <-\(self.videoFileURL.lastPathComponent)")
                            let image = self.drawNSImage(mainString: "\(tc) \n#\(Int(frameCount).paddedInt(numberOfDigit: 4))",secondaryString: "Created by\"Navet\"|  codec: \(self.videoCodec.rawValue) | fps:\(self.fps) | duration:\(self.numberOfSeconds) s | \(Int(self.width)) X \(Int(self.height))", width: self.width, height: self.height)
                            guard let cgImage = image.cgImage(forProposedRect: &rect, context: nil, hints: nil) else{
                                print("Cgimage creation did fail")
                                exit(EX__BASE)
                            }
                            var buffer: CVPixelBuffer?
                            let _ = CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferAdaptor.pixelBufferPool!, &buffer)
                            if let pixelBuffer = buffer{
                                pixelBuffer.drawCGImage(cgImage)
                                // Try to append
                                while (pixelBufferAdaptor.assetWriterInput.isReadyForMoreMediaData == false) {
                                    sleep(1/1000)
                                }
                                guard pixelBufferAdaptor.append(pixelBuffer,withPresentationTime: presentationTime) else{
                                    print("Pixel buffer addition did fail")
                                    exit(EX__BASE)
                                }
                            }else{
                                print("Pixel buffer creation did fail")
                                exit(EX__BASE)
                            }
                            currentProgress.completedUnitCount = frameCount
                            progress(currentProgress)
                        })
                    }
                    videoWriterInput.markAsFinished()
                    videoWriter.finishWriting {
                        if let error = videoWriter.error {
                            print("\(error)")
                            exit(EX__BASE)
                        } else {
                            exit(EX_OK)
                        }
                    }
                })
            }catch{
                print("\(error)")
                exit(EX__BASE)
            }
        }


        // Draw a NSImage
        public func drawNSImage(mainString:String,secondaryString:String?,width:CGFloat,height:CGFloat)->NSImage{
            let fontSize:CGFloat = self.width / 10
            let textRect = NSRect(x: 0, y: 0, width: width, height: height)
            let size = CGSize(width: width, height:height)
            let image = NSImage(size: size)
            image.lockFocus()
            NSGraphicsContext.saveGraphicsState()
            self._backGroundColor.setFill()
            textRect.fill()
            NSGraphicsContext.restoreGraphicsState()
            let textTextContent = mainString //"00:00:00:01"
            let textStyle = NSMutableParagraphStyle()
            textStyle.alignment = .center
            let textFontAttributes : [NSAttributedString.Key: Any]
            if #available(OSX 10.11, *) {
                textFontAttributes = [
                    .font: NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: NSFont.Weight.light),
                    .foregroundColor: self.textColor,
                    .paragraphStyle: textStyle,
                    ] as [NSAttributedString.Key: Any]
            } else {
                let font = NSFont.init(name: "Monaco", size: fontSize)!
                textFontAttributes = [
                    .font: font,
                    .foregroundColor: self.textColor,
                    .paragraphStyle: textStyle,
                    ] as [NSAttributedString.Key: Any]
            }
            let textTextHeight: CGFloat = textTextContent.boundingRect(with: NSSize(width: textRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: textFontAttributes).height
            let textTextRect: NSRect = NSRect(x: textRect.minX, y: textRect.minY + (textRect.height - textTextHeight) / 2, width: textRect.width, height: textTextHeight)
            NSGraphicsContext.saveGraphicsState()
            textRect.clip()
            textTextContent.draw(in: textTextRect.offsetBy(dx: 0, dy: 0), withAttributes: textFontAttributes)
            if let s = secondaryString{
                let textStyle = NSMutableParagraphStyle()
                textStyle.alignment = .right
                let textFontAttributes = [
                    .font: NSFont.systemFont(ofSize: self.width/50),
                    .foregroundColor: self.textColor,
                    .paragraphStyle: textStyle,
                    ] as [NSAttributedString.Key: Any]
                let textTextHeight: CGFloat = s.boundingRect(with: NSSize(width: textRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: textFontAttributes).height
                let textTextRect: NSRect = NSRect(x: textRect.minX, y: textRect.minY, width: textRect.width, height: textTextHeight)
                s.draw(in: textTextRect.offsetBy(dx: 0, dy: 0), withAttributes: textFontAttributes)

            }
            NSGraphicsContext.restoreGraphicsState()
            image.unlockFocus()
            return image
        }

        public init(){

        }
        // MARK: - Implementation




        fileprivate var n:Int{ return Int(round(self.numberOfSeconds * self.fps)) }

        // MARK: Color Management

        fileprivate  var _backGroundColor:NSColor{
            switch self.colorMode {
            case .progressive:
                switch self.currentColorComponent {
                case .r:
                    if self.currentR <= 1 - self.colorStep * 8 {
                        self.currentR += self.colorStep
                    }else{
                        self.currentR = 0
                        currentColorComponent = .g
                    }
                    break
                case .g:
                    if self.currentG <= 1 - self.colorStep * 8 {
                        self.currentG += self.colorStep
                    }else{
                        self.currentR = 0
                        self.currentG  = 0
                        currentColorComponent = .b
                    }
                    break
                case .b:
                    if self.currentB <= 1 - self.colorStep * 8 {
                        self.currentB += self.colorStep
                    }else{
                        currentColorComponent = .r
                        self.currentR = 0
                        self.currentG = 0
                        self.currentB = 0
                    }
                    break
                }
            case .random:
                // Pick a random color
                self.currentR = 1 / CGFloat(arc4random_uniform(255))
                self.currentG = 1 / CGFloat(arc4random_uniform(255))
                self.currentB = 1 / CGFloat(arc4random_uniform(255))
            case .uniform:
                // Do nothing
                break
            }
            return NSColor (calibratedRed: self.currentR , green:  self.currentG, blue:  self.currentB, alpha: 1)
        }


        fileprivate var textColor:NSColor {
            return NSColor.white
        }

        fileprivate var codec:AVVideoCodecType{
            switch self.videoCodec {
            case .hevc:
                if #available(OSX 10.13, *) {
                    return AVVideoCodecType.hevc
                } else {
                    // We use h264
                    return AVVideoCodecType(rawValue:AVVideoCodecH264)
                }
            case .h264:
                if #available(OSX 10.13, *) {
                    return AVVideoCodecType.h264
                } else {
                    return AVVideoCodecType(rawValue:AVVideoCodecH264)
                }
            case .jpeg:
                if #available(OSX 10.13, *) {
                    return AVVideoCodecType.jpeg
                } else {
                   return AVVideoCodecType(rawValue:AVVideoCodecJPEG)
                }
            case .proRes422:
                if #available(OSX 10.13, *) {
                    return AVVideoCodecType.proRes422
                } else {
                    return AVVideoCodecType(rawValue:AVVideoCodecAppleProRes422)
                }
            case .proRes4444:
                if #available(OSX 10.13, *) {
                    return AVVideoCodecType.proRes4444
                } else {
                    return AVVideoCodecType(rawValue:AVVideoCodecAppleProRes4444)
                }
            }
        }

        fileprivate var type:AVFileType{
            switch self.fileType {
            case .mov:
                return AVFileType.mov
            case .mp4:
                return AVFileType.mp4
            case .m4v:
                return AVFileType.m4v
            }
        }

    }
#endif

