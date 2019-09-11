//
//  DailySummaryItemView.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 11/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import UIKit

class DailySummaryItemView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var valueTxt: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func configure(image: UIImage, textContent : String)
    {
        iconImage.image = image
        valueTxt.text = textContent
    }
    
    func commonInit()
    {
        Bundle.main.loadNibNamed("DailySummaryItemView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
