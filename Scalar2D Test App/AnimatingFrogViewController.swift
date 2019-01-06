//
//  AnimatingFrogViewController.swift
//  Scalar2D iOS Test App
//
//  Created by Glenn Howes on 1/3/19.
//  Copyright © 2019 Generally Helpful Software. All rights reserved.
//

import UIKit
import Scalar2D

class AnimatingFrogViewController: UIViewController {

    @IBOutlet var frogView: PathView!
    @IBOutlet var strokeView: PathView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let duration: CFTimeInterval = 3.0
        
        self.strokeView.shapeLayer.strokeEnd = 0.0 // so it doesn't disappear after the animation
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = 1.0
        strokeAnimation.toValue = 0.0
        strokeAnimation.beginTime = 0
        strokeAnimation.duration = duration
        strokeAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        strokeAnimation.fillMode = CAMediaTimingFillMode.forwards
        
        let group = CAAnimationGroup()
        group.animations = [strokeAnimation]
        group.duration = duration
        
        
        // 6)
        self.strokeView.shapeLayer.add(group, forKey: "move")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
