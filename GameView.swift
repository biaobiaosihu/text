//
//  GameView.swift
//  Swift俄罗斯方块
//
//  Created by biao on 2017/4/24.
//  Copyright © 2017年 xbgph. All rights reserved.
//

import UIKit
import AVFoundation

protocol GameViewDelegate {
    func updateScore(score: Int)
    func updateSpeed(speed: Int)

}

// 重载+运算符，让+支持Int + Double运算
func + (left: Int , right:Double) -> Double
{
    return Double(left) + right
}
// 重载-运算符，让+支持Int - Double运算
func - (left: Int , right: Double) -> Double
{
    return Double(left) - right
}

class GameView: UIView {
    var delegate : GameViewDelegate!
    // 行
    var rows = 22
    // 列
    let column = 15
//    方格大小
    let cellSize :Int
    // 没方块是0
    let NO_Block = 0
    
    var ctx : CGContext!
    //定义一个实例，代表内存中的图片
    var image: UIImage!
    //定义消除音乐的对象
    var displayer: AVAudioPlayer!
    
    //定义方块的颜色
    let colors = [UIColor.white.cgColor,
                  UIColor.red.cgColor,
                  UIColor.green.cgColor ,
                  UIColor.blue.cgColor ,
                  UIColor.orange.cgColor ,
                  UIColor.magenta.cgColor ,
                  UIColor.purple.cgColor ,
                  UIColor.brown.cgColor]
    // 定义可能出现的方块组合
    var blockArr:[[Block]]
    // 当前出现下落的方块
    var currentBlock:[Block]!
    
    var tetris_status = [[Int]]()
    
    // 当前得分跟速度
    var currentScore:Int = 0
    var currentSpeed = 1
    //当前的计时器
    var currentTimer: Timer!
    
    
    override init(frame: CGRect) {
        self.blockArr = [
            // 代表第一种可能出现的方块组合：Z
            [
                Block(x: column / 2 - 1 , y:0 , color:1),
                Block(x: column / 2 , y:0 ,color:1),
                Block(x: column / 2 , y:1 ,color:1),
                Block(x: column / 2 + 1 , y:1 , color:1)
            ],
            // 代表第二种可能出现的方块组合：反Z
            [
                Block(x: column / 2 + 1 , y:0 , color:2),
                Block(x: column / 2 , y:0 , color:2),
                Block(x: column / 2 , y:1 , color:2),
                Block(x: column / 2 - 1 , y:1 , color:2)
            ],
            // 代表第三种可能出现的方块组合： 田
            [
                Block(x: column / 2 - 1 , y:0 , color:3),
                Block(x: column / 2 , y:0 ,  color:3),
                Block(x: column / 2 - 1 , y:1 , color:3),
                Block(x: column / 2 , y:1 , color:3)
            ],
            // 代表第四种可能出现的方块组合：L
            [
                Block(x: column / 2 - 1 , y:0 , color:4),
                Block(x: column / 2 - 1, y:1 , color:4),
                Block(x: column / 2 - 1 , y:2 , color:4),
                Block(x: column / 2 , y:2 , color:4)
            ],
            // 代表第五种可能出现的方块组合：J
            [
                Block(x: column / 2  , y:0 , color:5),
                Block(x: column / 2 , y:1, color:5),
                Block(x: column / 2  , y:2, color:5),
                Block(x: column / 2 - 1, y:2, color:5)
            ],
            // 代表第六种可能出现的方块组合 : 条
            [
                Block(x: column / 2 , y:0 , color:6),
                Block(x: column / 2 , y:1 , color:6),
                Block(x: column / 2 , y:2 , color:6),
                Block(x: column / 2 , y:3 , color:6)
            ],
            // 代表第七种可能出现的方块组合 : ┵
            [
                Block(x: column / 2 , y:0 , color:7),
                Block(x: column / 2 - 1 , y:1 , color:7),
                Block(x: column / 2 , y:1 , color:7),
                Block(x: column / 2 + 1, y:1 , color:7)
            ]
        ]
        // 方块大小
        self.cellSize = Int(frame.size.width) / column
        let shouldH = frame.size.height
        rows = Int(shouldH) / cellSize
        
        super.init(frame: frame)
        
        // 获取消除方块音效的url
        let disMusicUrl = Bundle.main.url(forResource: "shake", withExtension: "wav")
        do {
            try displayer = AVAudioPlayer(contentsOf: disMusicUrl!)
        } catch  {
            
        }
        displayer.numberOfLoops = 0
        
        // 开启内存中的绘图
        UIGraphicsBeginImageContext(self.bounds.size)
        // 获取Quartz 2D绘图的CGContextRef对象
        ctx = UIGraphicsGetCurrentContext()
        // 填充背景色
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fill(self.bounds)
        
        // 绘制俄罗斯方块的网格
        createCells(rows, cols:column ,
                    cellWidth :cellSize, cellHeight:cellSize)
        image = UIGraphicsGetImageFromCurrentImageContext()
    }
    func createCells(_ rows:Int, cols:Int , cellWidth :Int, cellHeight:Int)
    {
        // 开始创建路径
        ctx.beginPath()
        // 绘制横向
        for  i in 0...rows {
            ctx.move(to: CGPoint(x: 0, y: CGFloat(i * cellSize)))
            ctx.addLine(to: CGPoint(x: CGFloat(column * cellSize), y: CGFloat(i * cellSize)) )
        }
        
        // 绘制竖向
        for  i in 0...column {
            ctx.move(to: CGPoint(x: CGFloat(i * cellSize), y: 0) )
            ctx.addLine(to: CGPoint(x: CGFloat(i * cellSize), y: CGFloat(rows * cellSize)) )
        }
        ctx.closePath()
        // 设置笔触颜色
        ctx.setStrokeColor(UIColor(red: 0.9,
                                   green: 0.9, blue: 0.9, alpha: 1).cgColor)
        // 设置线条粗细
        ctx.setLineWidth(CGFloat(1.0))
        // 绘制线条
        ctx.strokePath()
    }
    
     func startGame ()
     {
        self.currentSpeed = 1
        self.delegate.updateSpeed(speed: self.currentSpeed)
        self.currentScore = 0
        self.delegate.updateScore(score: self.currentScore)
        
        initTetrisStats()
        
        initBlock()
        
        currentTimer = Timer.scheduledTimer(timeInterval: 0.6 / Double(currentSpeed), target: self, selector: #selector(blockMoveDown), userInfo: nil, repeats: true)
    }
    
    func initTetrisStats()
    {
        let tmpRow = Array(repeating: NO_Block, count: column)
        tetris_status = Array(repeating: tmpRow, count: rows)
        
    }
    
    // 随机生成一个下落的方块
    func initBlock()
    {
        let diceFaceCount: UInt32 = UInt32(blockArr.count)
        let randomRoll = Int(arc4random_uniform(diceFaceCount))
        // 正在下掉的方块
        currentBlock = blockArr[randomRoll]
    }
    
    func blockMoveDown()
    {
        //定义向下的旗标
        var canDown = true
        
        //判断当前的的滑块是不是可以下滑
        for i in 0  ..< currentBlock.count
        {
            
            //判断是否已经到底了
            if currentBlock[i].y >= rows - 1
            {
                canDown = false
                break
            }
            
            //判断下一个是不是有方块
            if tetris_status[currentBlock[i].y + 1][currentBlock[i].x] != NO_Block
            {
                canDown = false
                break
            }
        }
        
        if canDown
        {
            
            self.drawblock()
            //将下移前的方块白色
            for i in 0  ..< currentBlock.count
            {
                
                let cur = currentBlock[i]
                //设置填充颜色
                ctx.setFillColor(UIColor.white.cgColor)
                //绘制矩形
                ctx.fill(CGRect(x: CGFloat(cur.x * cellSize
                    + 1.0) , y: CGFloat(cur.y * cellSize + 1.0),
                                      width: CGFloat(cellSize - 1.0 * 2) ,
                                      height: CGFloat(cellSize - 1.0 * 2)))
            }
            
            //遍历每个方块，控制每个方块的y坐标加1
            for i in 0  ..< currentBlock.count
            {
                currentBlock[i].y += 1
            }
            //将下移的每个方块的背景涂成方块的颜色
            for i in 0  ..< currentBlock.count
            {
                
                let cur = currentBlock[i]
                //设置填充颜色
                ctx.setFillColor(colors[cur.color])
                //绘制矩形
                ctx.fill(CGRect(x: CGFloat(cur.x * cellSize
                    + 1.0) , y: CGFloat(cur.y * cellSize + 1.0),
                                      width: CGFloat(cellSize - 1.0 * 2) ,
                                      height: CGFloat(cellSize - 1.0 * 2)))
            }
        }
            //不能下落
        else
        {
            
            //遍历每个方块，把每个方块的值记录到tetris_status数组中
            for i in 0  ..< currentBlock.count
            {
                let cur = currentBlock[i]
                //如果有方块在最上边了，表明已经输了
                if cur.y < 2
                {
                    currentTimer.invalidate()
                    //显示提示框
                    let alert = UIAlertController(title: "游戏结束", message: "游戏已经结束，点击重新开始", preferredStyle:UIAlertControllerStyle.alert )
                    
                    let yeslAction = UIAlertAction(title: "重新开始", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
                        self.startGame()
                    })
                    
                    alert.addAction(yeslAction)
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                    
                    return
                    
                }
                //把每个方块当前所在的位置赋为当前方块的颜色值
                tetris_status[cur.y][cur.x] = cur.color
                
            }
            //判断是不是可消除
            lineFull()
            
            //开始新一组方块
            initBlock()
        }
        // 获取缓冲区的图片
        image = UIGraphicsGetImageFromCurrentImageContext()
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        // 获取绘图上下文
        _ = UIGraphicsGetCurrentContext()
        // 将内存中的image图片绘制在该组件的左上角
        image.draw(at: CGPoint.zero)
        
    }
    
    /**
        绘制方块的状态
     */
    func drawblock()
    {
        for i in 0..<rows {
            for j in 0..<column {
                // 有方块的地方绘制颜色
                if tetris_status[i][j] != NO_Block
                {
                    // 设置填充颜色
                    ctx.setFillColor(colors[tetris_status[i][j]])
                    // 绘制
                    ctx.fill(CGRect(x: CGFloat(j *  cellSize
                        + 1.0) , y: CGFloat(i * cellSize + 1.0),
                                          width: CGFloat(cellSize - 1.0 * 2) ,
                                          height: CGFloat(cellSize - 1.0 * 2)))
                }
                    // 没有方块的地方绘制白色
                else
                {
                    // 设置填充颜色
                    ctx.setFillColor(UIColor.white.cgColor)
                    // 绘制矩形
                    ctx.fill(CGRect(x: CGFloat(j * cellSize
                        + 1.0) , y: CGFloat(i * cellSize + 1.0),
                                          width: CGFloat(cellSize - 1.0 * 2) ,
                                          height: CGFloat(cellSize - 1.0 * 2)))
                }
            }
        }
    }
    
    
    /**
     判断是否有一行已满
     */
    func lineFull()
    {
        
        //依次便利每一行
        for i in 0  ..< rows
        {
            var flag = true
            //遍历当前行的每一个单元格
            for j in 0  ..< column
            {
                if tetris_status[i][j] == NO_Block
                {
                    flag = false
                    break
                }
            }
            //如果当前有全部方块了
            if flag
            {
                //将当前积分增加100
                currentScore += 100
                
                self.delegate.updateScore(score: currentScore)
                
                //如果当前积分达到升级极限升速度
                
                if currentScore >= currentSpeed * currentSpeed * 500
                {
                    //速度加1
                    currentSpeed += 1
                    self.delegate.updateSpeed(speed: currentSpeed)
                    //让原有计时器失效，开始新的计时器
                    currentTimer.invalidate()
                    currentTimer = Timer.scheduledTimer(timeInterval: 0.6 / Double(currentSpeed), target: self, selector: #selector(GameView.blockMoveDown), userInfo: nil, repeats: true)
                }
                //把当前行上边的所有方块下移一行
                for j in ((0 + 1)...i).reversed()
                {
                    for k in 0  ..< column
                    {
                        tetris_status[j][k] = tetris_status[j-1][k]
                    }
                }
                //播放消除方块的音乐
                if !displayer.isPlaying
                {
                    displayer.play()
                }
            }
        }
    }
    
    // 方块向左移动
    func moveLeft()
    {
        //定义能否左移
        var canLeft = true
        for i in 0  ..< currentBlock.count
        {
            //如果已经到了最左边
            if currentBlock[i].x <= 0
            {
                canLeft = false
                break
            }
            
            //或者左边已经有方块
            if tetris_status[currentBlock[i].y][currentBlock[i].x - 1] != NO_Block
            {
                canLeft = false
                break
            }
        }
        
        //如果能左移
        if canLeft
        {
            self.drawblock()
            //将左移前的方块涂成白色
            for i in 0  ..< currentBlock.count
            {
                let cur = currentBlock[i]
                
                ctx.setFillColor(UIColor.white.cgColor)
                ctx.fill(CGRect(x: CGFloat(cur.x * cellSize + 1.0), y: CGFloat(cur.y * cellSize + 1.0), width: CGFloat(cellSize - 1.0 * 2), height: CGFloat(cellSize - 1.0 * 2)))
            }
            
            //左移所有正在下降的方块
            for i in 0  ..< currentBlock.count
            {
                currentBlock[i].x -= 1
            }
            
            //将左移的方块渲染颜色
            for i in 0  ..< currentBlock.count
            {
                let cur = currentBlock[i]
                
                ctx.setFillColor(colors[cur.color])
                ctx.fill(CGRect(x: CGFloat(cur.x * cellSize + 1.0), y: CGFloat(cur.y * cellSize + 1.0), width: CGFloat(cellSize - 1.0 * 2), height: CGFloat(cellSize - 1.0 * 2)))
            }
            
            image = UIGraphicsGetImageFromCurrentImageContext()
            
            self.setNeedsDisplay()
        }
    }
    
    
    //方块右移的方法
    func moveRight()
    {
        //定义能否右移
        var canRight = true
        for i in 0  ..< currentBlock.count
        {
            //如果已经到了最右边
            if currentBlock[i].x >= column - 1
            {
                canRight = false
                break
            }
            
            //右边已经有方块
            if tetris_status[currentBlock[i].y][currentBlock[i].x + 1] != NO_Block
            {
                canRight = false
                break
            }
        }
        
        //如果能右移
        if canRight
        {
            self.drawblock()
            //将左移前的方块涂成白色
            for i in 0  ..< currentBlock.count
            {
                let cur = currentBlock[i]
                
                ctx.setFillColor(UIColor.white.cgColor)
                ctx.fill(CGRect(x: CGFloat(cur.x * cellSize + 1.0), y: CGFloat(cur.y * cellSize + 1.0), width: CGFloat(cellSize - 1.0 * 2), height: CGFloat(cellSize - 1.0 * 2)))
            }
            
            //右移所有正在下降的方块
            for i in 0  ..< currentBlock.count
            {
                currentBlock[i].x += 1
            }
            
            //将右移的方块渲染颜色
            for i in 0  ..< currentBlock.count
            {
                let cur = currentBlock[i]
                
                ctx.setFillColor(colors[cur.color])
                ctx.fill(CGRect(x: CGFloat(cur.x * cellSize + 1.0), y: CGFloat(cur.y * cellSize + 1.0), width: CGFloat(cellSize - 1.0 * 2), height: CGFloat(cellSize - 1.0 * 2)))
            }
            
            image = UIGraphicsGetImageFromCurrentImageContext()
            
            self.setNeedsDisplay()
        }
    }
    
    //旋转
    func blockRotate()
    {
        var canRotate = true
        for i in 0 ..< currentBlock.count {
            let preX = currentBlock[i].x
            let preY = currentBlock[i].y
            
            if i != 2
            {
                //计算旋转后的坐标
                let afterRotateX = currentBlock[2].x + preY - currentBlock[2].y
                let afterRotateY = currentBlock[2].y + currentBlock[2].x - preX
                //如果旋转后的x。y越界或者旋转后的位置已有方块，表明不能旋转
                if afterRotateX < 0 || afterRotateX > column - 1 || afterRotateY < 0 || afterRotateY > rows - 1||tetris_status[afterRotateY][afterRotateX] != NO_Block
                {
                    canRotate = false
                    break
                }
            }
        }
        if canRotate
        {
            for i in 0  ..< currentBlock.count
            {
                let cur = currentBlock[i]
                
                ctx.setFillColor(UIColor.white.cgColor)
                ctx.fill(CGRect(x: CGFloat(cur.x * cellSize + 1.0), y: CGFloat(cur.y * cellSize + 1.0), width: CGFloat(cellSize - 1.0 * 2), height: CGFloat(cellSize - 1.0 * 2)))
            }
            
            for i in 0  ..< currentBlock.count
            {
                let preX = currentBlock[i].x
                let preY = currentBlock[i].y
                
                if i != 2
                {
                    currentBlock[i].x = currentBlock[2].x + preY - currentBlock[2].y
                    currentBlock[i].y = currentBlock[2].y + currentBlock[2].x - preX
                }
                
            }
            
            for i in 0  ..< currentBlock.count
            {
                let cur = currentBlock[i]
                
                ctx.setFillColor(colors[cur.color])
                ctx.fill(CGRect(x: CGFloat(cur.x * cellSize + 1.0), y: CGFloat(cur.y * cellSize + 1.0), width: CGFloat(cellSize - 1.0 * 2), height: CGFloat(cellSize - 1.0 * 2)))
            }
            
            image = UIGraphicsGetImageFromCurrentImageContext()
            
            self.setNeedsDisplay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
