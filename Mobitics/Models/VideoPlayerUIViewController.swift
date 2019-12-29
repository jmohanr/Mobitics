//
//  VideoPlayerUIViewController.swift
//  Mobitics
//
//  Created by Vaayoo on 29/12/19.
//  Copyright © 2019 Jagan. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
extension VideoDetailsViewController {
    
    //MARK:- UI Creation Methods
    func addingEvents(){
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        let VideoDescriptionCell = UINib(nibName: self.cellID, bundle: nil)
        self.tableView.register(VideoDescriptionCell, forCellReuseIdentifier: self.cellID)
        self.videoPlayerButtons[1] .addTarget(self, action: #selector(rotatingVideoView(_ :)), for: .touchUpInside)
        self.videoPlayerButtons[2] .addTarget(self, action: #selector(playPauseButton(_ :)), for: .touchUpInside)
        self.videoPlayerButtons[3] .addTarget(self, action: #selector(forwardVideoButton(_ :)), for: .touchUpInside)
        self.videoPlayerButtons[4] .addTarget(self, action: #selector(backwoardVideoButton(_ :)), for: .touchUpInside)
        self.videoPlayerButtons[5] .addTarget(self, action: #selector(speakerTappedButton(_ :)), for: .touchUpInside)
        self.progressSlider.addTarget(self, action: #selector(self.handlePlayheadSliderValueChanged), for: .valueChanged)
        videoContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))

        
    }
    func sliderUI(){
        self.progressSlider.setThumbImage(UIImage(named: "sliderImage"), for: .normal)
        progressSlider.minimumTrackTintColor = UIColor.red
        //        progressSlider.isUserInteractionEnabled = false
        progressSlider.maximumTrackTintColor = UIColor.lightGray
        progressSlider.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
    
    //MARK:- Button Actions
    @objc func rotatingVideoView(_ sender:UIButton){
        if sender.isSelected == true {
            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            sender.isSelected = false
        }else{
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            sender.isSelected = true
        }
    }
    @objc func speakerTappedButton(_ sender:UIButton){
        if sender.isSelected == true {
            self.videoPlayerButtons[5].setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
            self.avPlayer.isMuted = true
            sender.isSelected = false
        }else{
            self.videoPlayerButtons[5].setImage(UIImage(systemName: "speaker.3.fill"), for: .normal)
            self.avPlayer.isMuted = false
            sender.isSelected = true
        }
    }
    @objc func playPauseButton(_ sender:UIButton){
        if sender.isSelected == true {
            self.avPlayer.pause()
            self.videoPlayerButtons[2].setImage(UIImage(systemName: "play.fill"), for: .normal)
            sender.isSelected = false
        }else{
            self.avPlayer.play()
            self.videoPlayerButtons[2].setImage(UIImage(systemName: "pause.fill"), for: .normal)
            sender.isSelected = true
        }
    }
    
    @objc func forwardVideoButton(_ sender:UIButton){
        guard let duration  = avPlayer.currentItem?.duration else{
            return
        }
        let playerCurrentTime = CMTimeGetSeconds(avPlayer.currentTime())
        let newTime = playerCurrentTime + seekDuration
        
        if newTime < CMTimeGetSeconds(duration) {
            
            let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            avPlayer.seek(to: time2)
        }
    }
    @objc func backwoardVideoButton(_ sender:UIButton){
        let playerCurrentTime = CMTimeGetSeconds(avPlayer.currentTime())
        var newTime = playerCurrentTime - seekDuration
        
        if newTime < 0 {
            newTime = 0
        }
        let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        avPlayer.seek(to: time2)
    }
    @IBAction func handlePlayheadSliderValueChanged(_ sender: UISlider) {
        let duration : CMTime = avPlayer.currentItem!.asset.duration
        let newCurrentTime: TimeInterval = Double(sender.value) * CMTimeGetSeconds(duration)
        let seekToTime: CMTime = CMTimeMakeWithSeconds(newCurrentTime, preferredTimescale: 600)
        avPlayer.seek(to: seekToTime)
    }
    
    
    //MARK:- AVPlayer Delegate Method
    @objc func playerDidFinishPlaying(note: NSNotification) {
        if let count = fetchedhResultController.sections?.first?.numberOfObjects {
            if videoCurrentIndexPath.row <= count {
                var index =  videoCurrentIndexPath.row
                index += 1
                if let video = fetchedhResultController.object(at: IndexPath(row: index, section: 0)) as? Videos {
                    self.selectedVideos = video
                    self.playingSelectedVideo(urlString: video.url ?? "", title: video.title ?? "", details: video.videoDescription ?? "")
                    tableView.reloadData()
                }
            }
        }
    }
    
    //MARK:- Navigation Methods
    @IBAction func closeView(_ sender: UIButton){
        updatingData(id: selectedVideos.id ?? "")
        avPlayer.pause()
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- VideoPalying Methods
    func playingSelectedVideo(urlString:String,title:String,details:String){
        if let url = URL(string: urlString ){
            self.videoTitleLbl.text = title
            self.videoDescriptionLbl.text = details
            avPlayer = AVPlayer(url: url)
            let controller = AVPlayerViewController()
            controller.player = avPlayer
            controller.view.frame = self.videoContainerView.bounds
            controller.view.tag = 100
            removeSubview()
            self.videoContainerView.addSubview(controller.view)
            controller.view.bringSubviewToFront(self.videoOverlayView)
            videoContainerView.bringSubviewToFront(self.videoOverlayView)
            self.addChild(controller)
            let timeIntvl: TimeInterval = TimeInterval(selectedVideos.videoDuration ?? "0")!
            let cmTime = CMTime(seconds: timeIntvl, preferredTimescale: 1000000)
            controller.showsPlaybackControls = false
            self.videoPlayerButtons[2].setImage(UIImage(systemName: "pause.fill"), for: .normal)
            self.avPlayer.seek(to: cmTime)
            self.avPlayer.play()
            let interval = CMTime(value: 1, timescale: 1)
            avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
                let seconds = CMTimeGetSeconds(progressTime)
                let hoursText = self.timeText(from: Int(seconds / 3600))
                let minutesText = self.timeText(from: Int(seconds / 60))
                let secondsText = self.timeText(from: Int(seconds) % 60)
                let duration : CMTime = self.avPlayer.currentItem!.asset.duration
                let totalSeconds : Float64 = CMTimeGetSeconds(duration)
                self.startTimeLabel.text = "\(hoursText):\(minutesText):\(secondsText)/\(self.stringFromTimeInterval(interval: totalSeconds))"
                if let duration = self.avPlayer.currentItem?.duration {
                    let durationSeconds = CMTimeGetSeconds(duration)
                    self.progressSlider.value = Float(seconds / durationSeconds)
                }
            })
        }
    }
    
    func removeSubview(){
        if let viewWithTag = self.videoContainerView.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }else{
        }
    }
    
    private func timeText(from number: Int) -> String {
        return number < 10 ? "0\(number)" : "\(number)"
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
