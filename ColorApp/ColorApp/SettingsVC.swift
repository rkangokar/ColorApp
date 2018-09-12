//
//  SettingsVC.swift
//  ColorApp
//
//  Created by Vineeth Menon on 6/28/18.
//  Copyright © 2018 Reshma. All rights reserved.
//

import Foundation
import UIKit

protocol SettingsViewControllerDelegate: class {
    func settingsViewControllerFinished(settingsViewController : SettingsVC)
}

class SettingsVC: UIViewController {
    
    // variables
    weak var delegate: SettingsViewControllerDelegate?
    
    @IBOutlet weak var brushSlider: UISlider!
    @IBOutlet weak var opacitySlider: UISlider!
    
    @IBOutlet weak var brushLabel: UILabel!
    @IBOutlet weak var opacityLabel: UILabel!
    
    @IBOutlet weak var brushImageView: UIImageView!
    @IBOutlet weak var opacityImageView: UIImageView!
    
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var greenLabel: UILabel!

    
    var brush: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     Change color by associating different RCB values sliders change in color is previewed in ImageView
     Argument : UISlider
     **/
    @IBAction func colorChanged(_ sender: UISlider!){
        red = CGFloat(redSlider.value / 255.0)
        redLabel.text = NSString(format: "%d", Int(redSlider.value)) as String
        green = CGFloat(greenSlider.value / 255.0)
        greenLabel.text = NSString(format: "%d", Int(greenSlider.value)) as String
        blue = CGFloat(blueSlider.value / 255.0)
        blueLabel.text = NSString(format: "%d", Int(blueSlider.value)) as String
        
        drawPreview()
    }
    
    /**
     Change in brush size and opacity sliders, is previewed in ImageView.
     Argument type -> UISlider
     **/
    @IBAction func sliderChanged(_ sender: UISlider){
        if sender == brushSlider {
            brush = CGFloat(sender.value)
            brushLabel.text = NSString(format: "%.2f", brush.native) as String
        } else {
            opacity = CGFloat(sender.value)
            opacityLabel.text = NSString(format: "%.2f", sender.value) as String
        }
        drawPreview()
    }
    
    /**
     Any change of value in sliders in Setting ViewController is previewed by updating the imageView
     Argument -> None
     **/
    func drawPreview() {
        UIGraphicsBeginImageContext(brushImageView.frame.size)
        var context = UIGraphicsGetCurrentContext()
        
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brush)
        
        context?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
        context?.move(to: CGPoint(x: 45.0, y: 45.0))
        context?.addLine(to: CGPoint(x: 45.0, y: 45.0))
        context?.strokePath()
        brushImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContext(brushImageView.frame.size)
        context = UIGraphicsGetCurrentContext()
        
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(20)
        context?.move(to: CGPoint(x: 45.0, y: 45.0))
        context?.addLine(to: CGPoint(x: 45.0, y: 45.0))
        
        context?.setStrokeColor(red: red, green: green, blue: blue, alpha: opacity)
        context?.strokePath()
        
        opacityImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
    // function dismisses the Settings ViewController when tapped on Close
    @IBAction func clickedClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.settingsViewControllerFinished(settingsViewController: self)
    }
    
    /**
     The brush size and opacity values are not modified when returned to settings viewController.
     While RGB should change based on the last selected color in Draw screen
     These should reflect in preview
     **/
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        brushSlider.value = Float(brush)
        brushLabel.text = NSString(format: "%.1f", brush.native) as String
        opacitySlider.value = Float(opacity)
        opacityLabel.text = NSString(format: "%.1f", opacity.native) as String
        redSlider.value = Float(red * 255.0)
        redLabel.text = NSString(format: "%d", Int(redSlider.value)) as String
        greenSlider.value = Float(green * 255.0)
        greenLabel.text = NSString(format: "%d", Int(greenSlider.value)) as String
        blueSlider.value = Float(blue * 255.0)
        blueLabel.text = NSString(format: "%d", Int(blueSlider.value)) as String
        
        drawPreview()
    }
    
}
