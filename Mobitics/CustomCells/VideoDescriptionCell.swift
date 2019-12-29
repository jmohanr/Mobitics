//
//  VideoDescriptionCell.swift
//  Mobitics
//
//  Created by Jagan on 27/12/19.
//  Copyright © 2019 Jagan. All rights reserved.
//

import UIKit

class VideoDescriptionCell: UITableViewCell {
    @IBOutlet weak var videoThumNailImage:UIImageView!
    @IBOutlet weak var titleLbl:UILabel!
    @IBOutlet weak var descriptionLbl:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func setPhotoCellWith(video: Videos) {
        DispatchQueue.main.async {
            guard let videoTitle = video.title else {return}
            self.titleLbl.text = videoTitle
            self.descriptionLbl.text = video.videoDescription
            if let url = video.thumb {
                self.videoThumNailImage.loadImageUsingCacheWithURLString(url, placeHolder: UIImage(named: "placeholder"))
            }
        }
    }
}
