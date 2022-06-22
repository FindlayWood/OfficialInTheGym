//
//  URL+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import AVFoundation

extension URL {
    /// function to compress video quality
    /// reduce the size of video but try to keep video quality as close to original
    func compressVideoSize(completion: @escaping (URL) -> Void) {
        var assetWriter: AVAssetWriter!
        var assetWriterVideoInput: AVAssetWriterInput!
        var audioMicInput: AVAssetWriterInput!
        var videoURL: URL!
        var audioAppInput: AVAssetWriterInput!
        var channelLayout = AudioChannelLayout()
        var assetReader: AVAssetReader?
        let bitrate: NSNumber = NSNumber(value: 1250000) // *** you can change this number to increase/decrease the quality. The more you increase, the better the video quality but the the compressed file size will also increase
        
        var audioFinished = false
        var videoFinished = false
        
        let asset = AVAsset(url: self)
        
        //create asset reader
        do {
            assetReader = try AVAssetReader(asset: asset)
        } catch {
            assetReader = nil
        }
        
        guard let reader = assetReader else {
            print("Could not iniitalize asset reader probably failed its try catch")
            // show user error message/alert
            return
        }

        guard let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first else { return }
         let videoReaderSettings: [String:Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB]
         
         let assetReaderVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
         
         var assetReaderAudioOutput: AVAssetReaderTrackOutput?
         if let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first {
             
             let audioReaderSettings: [String : Any] = [
                 AVFormatIDKey: kAudioFormatLinearPCM,
                 AVSampleRateKey: 44100,
                 AVNumberOfChannelsKey: 2
             ]
             
             assetReaderAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: audioReaderSettings)
             
             if reader.canAdd(assetReaderAudioOutput!) {
                 reader.add(assetReaderAudioOutput!)
             } else {
                 print("Couldn't add audio output reader")
                 // show user error message/alert
                 return
             }
         }
        
        if reader.canAdd(assetReaderVideoOutput) {
             reader.add(assetReaderVideoOutput)
         } else {
             print("Couldn't add video output reader")
             // show user error message/alert
             return
         }
         
         let videoSettings:[String:Any] = [
             AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: bitrate],
             AVVideoCodecKey: AVVideoCodecType.h264,
             AVVideoHeightKey: videoTrack.naturalSize.height,
             AVVideoWidthKey: videoTrack.naturalSize.width,
             AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill
         ]
         
         let audioSettings: [String:Any] = [AVFormatIDKey : kAudioFormatMPEG4AAC,
                                            AVNumberOfChannelsKey : 2,
                                            AVSampleRateKey : 44100.0,
                                            AVEncoderBitRateKey: 128000
         ]
        
        let audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioSettings)
        let videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
        videoInput.transform = videoTrack.preferredTransform
        
        let videoInputQueue = DispatchQueue(label: "videoQueue")
        let audioInputQueue = DispatchQueue(label: "audioQueue")
        
        do {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
            let date = Date()
            let tempDir = NSTemporaryDirectory()
            let outputPath = "\(tempDir)/\(formatter.string(from: date)).mp4"
            let outputURL = URL(fileURLWithPath: outputPath)
            
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mp4)
            
        } catch {
            assetWriter = nil
        }
        
        guard let writer = assetWriter else {
                print("assetWriter was nil")
                // show user error message/alert
                return
            }
            
            writer.shouldOptimizeForNetworkUse = true
            writer.add(videoInput)
            writer.add(audioInput)
            
            writer.startWriting()
            reader.startReading()
            writer.startSession(atSourceTime: CMTime.zero)
            
            let closeWriter: () -> Void = {
                if (audioFinished && videoFinished) {
                    assetWriter?.finishWriting(completionHandler: {
                        
                        if let assetWriter = assetWriter {
                            do {
                                let data = try Data(contentsOf: assetWriter.outputURL)
                                print("compressFile - Data Count: \(data.count)")
                                print("compressFile - file size after compression: \(Double(data.count / 1048576)) mb")
                                let bcf = ByteCountFormatter()
                                bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
                                bcf.countStyle = .file
                                let string = bcf.string(fromByteCount: Int64(data.count))
                                print("formatted result: \(string)")
                            } catch let err as NSError {
                                print("compressFile Error: \(err.localizedDescription)")
                            }
                        }
                        completion(assetWriter.outputURL)
//                        if let safeSelf = self, let assetWriter = safeSelf.assetWriter {
//                            completion(assetWriter.outputURL)
//                        }
                    })
                    
                    assetReader?.cancelReading()
                }
            }
        
        audioInput.requestMediaDataWhenReady(on: audioInputQueue) {
            while(audioInput.isReadyForMoreMediaData) {
                if let cmSampleBuffer = assetReaderAudioOutput?.copyNextSampleBuffer() {
                    
                    audioInput.append(cmSampleBuffer)
                    
                } else {
                    audioInput.markAsFinished()
                    DispatchQueue.main.async {
                        audioFinished = true
                        closeWriter()
                    }
                    break;
                }
            }
        }
        
        videoInput.requestMediaDataWhenReady(on: videoInputQueue) {
            // request data here
            while(videoInput.isReadyForMoreMediaData) {
                if let cmSampleBuffer = assetReaderVideoOutput.copyNextSampleBuffer() {
                    
                    videoInput.append(cmSampleBuffer)
                    
                } else {
                    videoInput.markAsFinished()
                    DispatchQueue.main.async {
                        videoFinished = true
                        closeWriter()
                    }
                    break;
                }
            }
        }
    }
    
    func removeUrlFromFileManager() {
        let path = self.path
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
                print("url SUCCESSFULLY removed: \(self)")
            } catch {
                print("Could not remove file at url: \(self)")
            }
        }
    }

}
