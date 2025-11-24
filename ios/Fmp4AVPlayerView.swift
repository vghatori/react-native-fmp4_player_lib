//
//  Fmp4AVPlayer.swift
//  fmp4_player
//
//  Created by Giáp Phan Văn on 28/10/25.
//

import UIKit
import AVFoundation
import AVKit


@objcMembers
public class Fmp4AVPlayerView: UIView {
  private static var avlayer : AVPlayerLayer?
  private static var playerViewController = AVPlayerViewController()
  override init(frame: CGRect) {
      super.init(frame: frame)
      commonInit()
  }

  required init?(coder: NSCoder) {
      super.init(coder: coder)
      commonInit()
  }

  private func commonInit() {
    Fmp4AVPlayerView.playerViewController.showsPlaybackControls = true
    self.addSubview(Fmp4AVPlayerView.playerViewController.view)
  }
  
  public func setStreamID(_ Id : String) {
    NativeFmp4PlayerLib.streamId = Id
  }
  
  static func AttachPlayerToLayer(avplayer : AVPlayer) {
    playerViewController.player = avplayer
  }

  
  public override func layoutSubviews() {
    super.layoutSubviews()
    Fmp4AVPlayerView.playerViewController.view.frame = bounds
  }

}
