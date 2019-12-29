//
//  VideoDetailsViewController.swift
//  Mobitics
//
//  Created by Jagan on 27/12/19.
//  Copyright © 2019 Jagan. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import CoreData
class VideoDetailsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var selectedVideos = Videos()
    var avPlayer = AVPlayer()
    var videoCurrentIndexPath = IndexPath()
    let seekDuration: Float64 = 10
    
    @IBOutlet weak var videoViewHeightConstrain:NSLayoutConstraint!
    @IBOutlet weak var topViewHeightConstrain:NSLayoutConstraint!
    @IBOutlet weak var videoContainerView:UIView!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var videoTitleLbl:UILabel!
    @IBOutlet weak var videoDescriptionLbl:UILabel!
    @IBOutlet weak var videoOverlayView:UIView!
    @IBOutlet var videoPlayerButtons: [UIButton]!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!

    let cellID = "VideoDescriptionCell"
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Videos.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    //MARK:- ViewController LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playingSelectedVideo(urlString: selectedVideos.url ?? "", title: selectedVideos.title ?? "", details: selectedVideos.videoDescription ?? "")
        updateTableContent()
        addingEvents()
        sliderUI()
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedhResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! VideoDescriptionCell
        if let photo = fetchedhResultController.object(at: indexPath) as? Videos {
            if photo.id == selectedVideos.id {
                cell.contentView.backgroundColor = UIColor.red
            }else{
                cell.contentView.backgroundColor = UIColor.white
            }
            cell.setPhotoCellWith(video: photo)
        }
        return cell
    }
    
    //MARK:- TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        avPlayer.pause()
        let index = tableView.indexPathForSelectedRow
        updatingData(id: selectedVideos.id ?? "")
        if let video = fetchedhResultController.object(at: index ?? indexPath) as? Videos {
            videoCurrentIndexPath = index ?? indexPath
            self.selectedVideos = video
            self.playingSelectedVideo(urlString: video.url ?? "", title: video.title ?? "", details: video.videoDescription ?? "")
            tableView.reloadData()
        }
    }
    
    
    func cmTimeToSeconds(_ time: CMTime) -> TimeInterval? {
        let seconds = CMTimeGetSeconds(time)
        if seconds.isNaN {
            return nil
        }
        return TimeInterval(seconds)
    }
    
    
    //MARK:-Updating Coredata record
    func updatingData(id:String){
        let currentItem = avPlayer.currentItem
        guard let timeInterVals = cmTimeToSeconds(currentItem?.currentTime() ?? CMTime()) else { return  }
        let seconds = NSInteger(timeInterVals)
        self.Update(identifier: id, name: "\(seconds)")
    }
    
    func Update(identifier: String,name:String) {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Videos")
        let predicate = NSPredicate(format: "id = '\(identifier)'")
        fetchRequest.predicate = predicate
        do {
            let object = try context.fetch(fetchRequest)
            if object.count == 1 {
                let objectUpdate = object.first as! NSManagedObject
                objectUpdate.setValue(name, forKey: "videoDuration")
                do{
                    try context.save()
                }
                catch {
                    print("ERROR: \(error)")
                }
            }
        }
        catch {
            print("ERROR: \(error)")
        }
    }
}
extension VideoDetailsViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func updateTableContent() {
        do {
            try self.fetchedhResultController.performFetch()
            print("COUNT FETCHED FIRST: \(String(describing: self.fetchedhResultController.sections?[0].numberOfObjects))")
        } catch let error  {
            print("ERROR: \(error)")
        }
    }
    //MARK:- Methods for device orientation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let bounds = UIScreen.main.bounds
        let height = bounds.size.height
        if UIDevice.current.orientation.isLandscape {
            self.videoViewHeightConstrain.constant = height
            self.topViewHeightConstrain.constant = 5
            self.videoPlayerButtons[0].isHidden = true
        }else{
            self.videoViewHeightConstrain.constant = 300
            self.topViewHeightConstrain.constant = 44
            self.videoPlayerButtons[0].isHidden = false
        }
    }
    func hideUnHideView(){
        if bottomView.isHidden == true || videoOverlayView.isHidden == true  {
            bottomView.fadeIn()
            bottomView.isHidden = false
            videoOverlayView.fadeIn()
            videoOverlayView.isHidden = false
        }else if bottomView.isHidden == false || videoOverlayView.isHidden == true{
            bottomView.fadeOut()
            bottomView.isHidden = true
            videoOverlayView.fadeOut()
            videoOverlayView.isHidden = true
        }
    }
    @objc  func handleTap(){
        hideUnHideView()
    }
}
