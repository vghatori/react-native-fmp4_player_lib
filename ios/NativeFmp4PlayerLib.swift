//
//  File.swift
//  fmp4_player
//
//  Created by Giáp Phan Văn on 24/10/25.
//

import Foundation

import AVFoundation
import Swifter
@objcMembers
public class NativeFmp4PlayerLib: NSObject {
  public static var streamId : String?
  private var url : URL?
  private var socketSession : URLSession?
  private var socketTask : URLSessionWebSocketTask?
  private static var player : AVPlayer?
  private let SEGMENT_DURATION : Double = 1.1
  private var LastPushSegmentTime = CACurrentMediaTime()
  private var FileURL : URL?
  private var playerItem: AVPlayerItem?
  private var proxyServer : HttpServer?
  private let tmpDir = FileManager.default.temporaryDirectory
  private var hlsDir : URL
  private var segmentCount = 0
  private var endStream = false
  private var connectStream = false
  private var SegmentBuffer : [Data]
  private var initSegment : Data?
  
  @objc
  public override init() {
    self.socketSession = nil
    self.socketTask = nil
    self.hlsDir = tmpDir.appendingPathComponent("hls")
    self.proxyServer = HttpServer()
    self.SegmentBuffer = []
    super.init()
  }
  
  @available(iOS 16.0, *)
  public func startStreaming() {
    //proxyServer?.addGETHandler(forBasePath: "/", directoryPath: hlsDir.path(), indexFilename: nil, cacheAge: 0, allowRangeRequests: true)
    proxyServer?["/:path"] = shareFilesFromDirectory(hlsDir.path())
    try? FileManager.default.createDirectory(atPath: hlsDir.path(), withIntermediateDirectories: true)
    try? proxyServer?.start(8080)
    //060f350f-9da8-422d-b14d-eb9642bea92a
    url = URL(string: "wss://sfu-do-streaming.ermis.network/stream-gate/software/Ermis-streaming/\(NativeFmp4PlayerLib.streamId!)")!
    var request = URLRequest(url: url!)
    request.addValue("fmp4", forHTTPHeaderField: "Sec-WebSocket-Protocol")
    self.socketSession = URLSession(configuration: .default)
    self.socketTask = socketSession?.webSocketTask(with: request)
    readMessage()
  }
  private func isInitSegment(_ data: Data) -> Bool {
    return data.count > 8 && String(data: data.subdata(in: 5..<9), encoding: .ascii) == "ftyp"
  }
  
  public func stopStreaming() {
    socketTask?.cancel(with: .goingAway, reason: nil)
    endStream = true
  }
  
  
  @available(iOS 16.0, *)
  private func readMessage() {
    socketTask?.resume();
    socketTask?.receive { result in
      switch result {
        case .failure(let error): print("fail : \(error)")
        case .success(let message):
            switch message {
              case .data(let data):
                guard !data.isEmpty else {
                  return
                }
              self.sendFrameToAVPlayer(data.dropFirst())
            case .string(let config):
                guard !config.isEmpty else {
                  return
                }
              @unknown default:
                break
            }
        self.readMessage()
      }
    }
  }

  private func appendBuffer(_ buffer: Data) {
    if isInitSegment(buffer) {
      let initUrl = hlsDir.appendingPathComponent("init.mp4")
      try? buffer.write(to: initUrl)
      return
    }

    SegmentBuffer.append(buffer)
    let now = CACurrentMediaTime()
    if now - LastPushSegmentTime > SEGMENT_DURATION {
      WriteBufferToSegment()
      LastPushSegmentTime = now
    }
    
  }
  
  @available(iOS 16.0, *)
  private func sendFrameToAVPlayer(_ data: Data) {
    appendBuffer(data)
    var playlist = "#EXTM3U\n"
    playlist.append("#EXT-X-VERSION:7\n")
    playlist.append("#EXT-X-TARGETDURATION:3\n")
    
    // Keep only last 5 segments
    let startSegment = max(0, segmentCount - 5)
    playlist.append("#EXT-X-MEDIA-SEQUENCE:\(startSegment)\n")

    playlist.append("#EXT-X-MAP:URI=\"init.mp4\"\n")
    
    for i in max(0, segmentCount - 5)..<segmentCount {
      playlist.append("#EXTINF:\(Double(round(1000*1.100)/1000)),\n")
      playlist.append("/segment-\(i).m4s\n")
    }
    if endStream {
      playlist.append("#EXT-X-ENDLIST")
    }
    
    let playlistUrl = hlsDir.appendingPathComponent("playlist.m3u8")
    try? playlist.write(toFile: playlistUrl.path(), atomically: true, encoding: .utf8)
    if(segmentCount == 1 && !connectStream) {
      startPlayer()
    }
  }
  
  private func startPlayer() {
      connectStream = true
      
      let playlistURL = URL(string: "http://localhost:8080/playlist.m3u8")!
     
      
    let asset = AVURLAsset(url: playlistURL)
      let playerItem = AVPlayerItem(asset: asset)
      playerItem.preferredForwardBufferDuration = 1.0
      playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
      NativeFmp4PlayerLib.player = AVPlayer(playerItem: playerItem)
      NativeFmp4PlayerLib.player?.automaticallyWaitsToMinimizeStalling = false
      Fmp4AVPlayerView.AttachPlayerToLayer(avplayer: NativeFmp4PlayerLib.player!)
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        NativeFmp4PlayerLib.player?.play()
      }
    }
  
  private func WriteBufferToSegment() {
    var segmentData = Data()
    let segmentName = "segment-\(segmentCount).m4s"
    let segmentURL = hlsDir.appendingPathComponent(segmentName)
    SegmentBuffer.forEach { data in
        segmentData.append(data)
    }

    try? segmentData.write(to: segmentURL)
    SegmentBuffer.removeAll()
    segmentCount += 1
  }

}
