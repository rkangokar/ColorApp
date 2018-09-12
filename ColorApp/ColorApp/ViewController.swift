//
//  ViewController.swift
//  ColorApp
//
//  Created by Vineeth Menon on 6/28/18.
//  Copyright © 2018 Reshma. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // variables
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!

    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    let colors: [(CGFloat, CGFloat, CGFloat)] = [
        (0, 0, 0),
        (105.0 / 255.0, 105.0 / 255.0, 105.0 / 255.0),
        (1.0, 0, 0),
        (0, 0, 1.0),
        (51.0 / 255.0, 204.0 / 255.0, 1.0),
        (102.0 / 255.0, 204.0 / 255.0, 0),
        (102.0 / 255.0, 1.0, 0),
        (160.0 / 255.0, 82.0 / 255.0, 45.0 / 255.0),
        (1.0, 102.0 / 255.0, 0),
        (1.0, 1.0, 0),
        (1.0, 1.0, 1.0),
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
     touchesBegan function fetches the first point the screen was touched. Supports multi-touch
     Argument types -> Set<UITouch>, UIEvent
     **/
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
        }
    }
    
    /**
     function drawLine used to draw betwwen the two points passed
     Argument type : CGPoint
     **/
    func drawLine(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.draw(in: view.bounds)
        
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushWidth)
        context?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
        context?.setBlendMode(CGBlendMode.normal)
        
        context?.strokePath()
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity

        UIGraphicsEndImageContext()
    }

    /**
     touchesMoved function updates the position of last touch to drawLine
     Argument -> Set<UITouch>, UIEvent
     **/
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            drawLine(fromPoint: lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
        }
    }
    
    /**
     touchesEnded function updates the last position of touch to drawLine and update the imageView
     Argument -> Set<UITouch>, UIEvent
     **/
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            drawLine(fromPoint: lastPoint, toPoint: lastPoint)
        }
        tempImageView.alpha = 0
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: view.bounds, blendMode: CGBlendMode.normal, alpha: 1.0)
        tempImageView.image?.draw(in: view.bounds, blendMode: CGBlendMode.normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }

    /**
     function will clear the screen
     Argument type -> Any
     **/
    @IBAction func clickedReset(_ sender: Any) {
        mainImageView.image = nil
    }
    
    /**
     Allows user to share the drawing or save to device.
     Argument type -> Any
     **/
    @IBAction func clickedShare(_ sender: Any) {
        UIGraphicsBeginImageContext(mainImageView.bounds.size)
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: mainImageView.frame.size.width, height: mainImageView.frame.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let activity  = UIActivityViewController(activityItems: [image as Any], applicationActivities: nil)
        present(activity, animated: true, completion: nil)
    }
    
    /**
     Allows user to select the color pencil for drawing
     Argument type -> Any
     **/
    @IBAction func pencilPressed(_ sender: Any) {
        var index = (sender as AnyObject).tag ?? 0
        if index < 0 || index >= colors.count {
            index = 0
        }
        (red, green, blue) = colors[index]
        if index == colors.count - 1 {
            opacity = 1.0
        }
    }
    
    /**
     Settings brush thickness and opacity values are matched with Settings ViewController
     Argument type -> UIStoryboardSegue, Any
     **/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let settingsViewController = segue.destination as! SettingsVC
        settingsViewController.delegate = self
        settingsViewController.brush = brushWidth
        settingsViewController.opacity = opacity
        settingsViewController.red = red
        settingsViewController.green = green
        settingsViewController.blue = blue
    }
    
}


extension ViewController: SettingsViewControllerDelegate{
    
    /**
     Settings brush thickness and opacity values are matched with ViewController variables
     Argument type -> UIStoryboardSegue, Any
     **/
    func settingsViewControllerFinished(settingsViewController: SettingsVC) {
        self.brushWidth = settingsViewController.brush
        self.opacity = settingsViewController.opacity
        self.red = settingsViewController.red
        self.green = settingsViewController.green
        self.blue = settingsViewController.blue
    }
}

