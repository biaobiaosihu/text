//
//  ViewController.swift
//  Swift俄罗斯方块
//
//  Created by biao on 2017/4/24.
//  Copyright © 2017年 xbgph. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController ,GameViewDelegate{

    let BUTTON_SIZE:CGFloat = 50
    var screenW: CGFloat!
    var screenH: CGFloat!
    var speedShow:UILabel!
    var scoreShow:UILabel!
    var gameView : GameView!
    var bgMusicPlayer: AVAudioPlayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let rect = UIScreen.main.bounds
        screenW  = rect.size.width
        screenH = rect.size.height
        addToolBtn()
        let gameViewRect = CGRect(x: rect.origin.x + 10, y: rect.origin.y + 44 + 10 * 2, width: rect.size.width - 10 * 2, height: rect.size.height - 48 * 2 - 44)
        gameView = GameView(frame:gameViewRect)
        gameView.delegate = self
        self.view.addSubview(gameView)
        //开始运行
        gameView.startGame()
        
        // 添加底部控制按钮
        addbottomBtns()
        
        
        //添加背景音乐
        let bgMusicUrl = Bundle.main.url(forResource: "1757", withExtension: "mp3")
        
        do
        {
            try bgMusicPlayer = AVAudioPlayer(contentsOf: bgMusicUrl!)
        }catch
        {
            
        }
        bgMusicPlayer.numberOfLoops = -1
        bgMusicPlayer.play()
        
    }
    func addToolBtn(){
        let toolBar = UIToolbar(frame: CGRect(x:0, y:20 ,width: screenW, height:44))
        self.view.addSubview(toolBar)
        // 速度label
        let speedLB = UILabel()
        speedLB.frame = CGRect(x:0, y:0, width:50, height:44)
        speedLB.text = "速度:"
        let speedLBItem = UIBarButtonItem(customView: speedLB)
        // 显示速度的Label
        speedShow = UILabel()
        speedShow.frame = CGRect(x: 0, y: 0, width: 20, height: 44)
        speedShow.textColor = UIColor.red
        let speedShowItem = UIBarButtonItem(customView: speedShow)
        
        // 积分Label
        let scoreLabel = UILabel()
        scoreLabel.frame = CGRect(x: 0, y: 0, width: 90, height: 44)
        scoreLabel.text = "当前积分:"
        let scoreLabelItem = UIBarButtonItem(customView: scoreLabel)
        
        // 显示积分label
        scoreShow = UILabel()
        scoreShow.frame = CGRect(x: 0, y: 0, width: 40, height: 44)
        scoreShow.textColor = UIColor.red
        let scoreShowItem = UIBarButtonItem(customView: scoreShow)
        
        let flexItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.items = [speedLBItem,speedShowItem,flexItem,scoreLabelItem,scoreShowItem]
    }
    func addbottomBtns()
    {
        // 左
        let leftBtn = UIButton()
        leftBtn.frame = CGRect(x:  20, y: screenH - BUTTON_SIZE - 30, width: BUTTON_SIZE, height: BUTTON_SIZE)
        leftBtn.setTitle("左", for: UIControlState())
        leftBtn.setTitleColor(UIColor.orange, for: UIControlState())
        leftBtn.addTarget(self, action: #selector(ViewController.left(_:)), for: UIControlEvents.touchUpInside)
        leftBtn.backgroundColor = UIColor.blue
        self.view.addSubview(leftBtn)

        
        //右
        let rightBtn = UIButton()
        rightBtn.frame = CGRect(x: BUTTON_SIZE * 2 + 60, y: screenH - BUTTON_SIZE - 30, width: BUTTON_SIZE, height: BUTTON_SIZE)
        rightBtn.setTitle("右", for: UIControlState())
        rightBtn.setTitleColor(UIColor.orange, for: UIControlState())
        rightBtn.addTarget(self, action: #selector(ViewController.right(_:)), for: UIControlEvents.touchUpInside)
        rightBtn.backgroundColor = UIColor.blue
        self.view.addSubview(rightBtn)
        
        //下
        let downBtn = UIButton()
        downBtn.frame = CGRect(x: BUTTON_SIZE  + 40, y: screenH - BUTTON_SIZE - 30, width: BUTTON_SIZE, height: BUTTON_SIZE)
        downBtn.setTitle("下", for: UIControlState())
        downBtn.setTitleColor(UIColor.orange, for: UIControlState())
        downBtn.addTarget(self, action: #selector(ViewController.down(_:)), for: UIControlEvents.touchUpInside)
        downBtn.backgroundColor = UIColor.blue
        self.view.addSubview(downBtn)
        
        //
        let changeBtn = UIButton()
        changeBtn.frame = CGRect(x: screenW - BUTTON_SIZE - 50, y: screenH - BUTTON_SIZE - 30, width: BUTTON_SIZE, height: BUTTON_SIZE)
        changeBtn.titleLabel?.textAlignment = .right
        changeBtn.setTitle("旋转", for: UIControlState())
        changeBtn.setTitleColor(UIColor.red, for: UIControlState())
        changeBtn.addTarget(self, action: #selector(ViewController.rotate(_:)), for: UIControlEvents.touchUpInside)
        changeBtn.backgroundColor = UIColor.blue
        self.view.addSubview(changeBtn)
    }
    
    //按钮点击事件
    func left(_ sender:UIButton)
    {
        gameView.moveLeft()
    }
    
    func up(_ sender:UIButton)
    {
        gameView.blockRotate()
    }
    
    func right(_ sender:UIButton)
    {
        gameView.moveRight()
    }
    
    func down(_ sender:UIButton)
    {
        gameView.blockMoveDown()
    }
    
    func rotate(_ sender:UIButton)
    {
        print("旋转")
        gameView.blockRotate()
    }
    // 代理方法
    func updateScore(score: Int) {
        self.scoreShow.text = "\(score)"
    }

    func updateSpeed(speed: Int) {
        self.speedShow.text = "\(speed)"
    }
}

