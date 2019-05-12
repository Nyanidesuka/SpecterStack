//
//  GameScene.swift
//  SpecterStack
//
//  Created by Haley Jones on 5/10/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import SpriteKit
import GameplayKit

class Block: SKSpriteNode{
    
}

class GameScene: SKScene {
    var blockColors = ["redBlock3x", "blueBlock3x", "greenBlock3x", "yellowBlock3x"]
    var matchedFriends: [SKSpriteNode] = []
    //we just use thi baseblock to take measurements honestly
    let baseBlock = SKSpriteNode(imageNamed: "redBlock3x")
    var playField: [[CGPoint]] = []
    var stackHeight = 11
    let stackBottomY: CGFloat = 96
    //let marginInt = (Int(view.bounds.width) % Int(tileSize) / 2 )
    //but actually we dont even need that because i know i want a hard limit of 6 wide
    
    //this will execute when we first enter this view
    override func didMove(to view: SKView) {
        var tileSize = baseBlock.size.width
        let marginSize = (view.bounds.width - (6 * tileSize)) / 2
        //let's set up the background.
        let background = SKSpriteNode(imageNamed: "checkboard3x")
        background.zPosition = -1
        for y in stride(from: 24, to: view.bounds.height, by: background.frame.height){
            for x in stride(from: 24, to: view.bounds.width, by: background.frame.width){
                let newBackground = SKSpriteNode(imageNamed: "checkboard3x")
                newBackground.position = CGPoint(x: x, y: y)
                addChild(newBackground)
            }
        }
        print(view.bounds.width)
        //now we're gonna establish the playgrid.
        for x in stride(from: marginSize + (tileSize / 2), to: view.bounds.width - (marginSize - (tileSize / 2)), by: tileSize){
            var newArray: [CGPoint] = []
            for y in stride(from: stackBottomY, to: (tileSize * CGFloat(stackHeight)) + (tileSize * 2), by: tileSize){
                let newPoint = CGPoint(x: x, y: y)
                print(newPoint)
                newArray.append(newPoint)
            }
            playField.append(newArray)
        }
        print(playField)
        //and now we have a big honkin' array of arrays of points, and accessing it goes like playfield[x][y] haaaaaaaa thats so good.
        
        //Put random blocks in the array
        for i in 0...4{ // y, which row
            for j in 0...5{ // x, which column
                let blockColor: String = blockColors.randomElement()!
                let newNode = Block(imageNamed: blockColor)
                newNode.name = blockColor
                newNode.position = playField[j][i]
                addChild(newNode)
            }
        }
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    //this function runs when the user taps
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        //and we're gonna check to see if, at that tap, there's a block.
        //first we grab the touch position
        //the passed in "touches" property is an array of touch inputs. We just want the first.
        //we ask where in this view (self) that touch was.
        guard let touchPosition = touches.first?.location(in: self) else {return}
        //so now we know where was touched. And we're gonna see what, if any, nodes were touched. Just the first one please.
        guard let tappedBlock = nodes(at: touchPosition).first(where: {$0 is Block}) as? Block else {return}
        moveToTopOfStack(block: tappedBlock)
        stackGravity()
        checkForMatches()
    }
    
    //MARK: Stack Management
    
    func moveToTopOfStack(block: Block){
        //find how high we gotta go to get to the top.
        var targetPosition = block.position
        let tileSize = block.frame.width
        var foundASpot = false
        while targetPosition.y <= (tileSize * CGFloat(stackHeight)) + (tileSize * 2) && foundASpot == false{
            let occupancy = nodes(at: targetPosition)
            if occupancy.contains(where: {$0 is Block}){
                targetPosition.y += tileSize
            } else {
                foundASpot = true
                block.position = targetPosition
            }
        }
    }
    
    func stackGravity(){
        //this should wind up checking from bottom to top which should make blocks fall all smoov and nice
        for i in 0...stackHeight - 1{ //row
            for j in 0...5{ //column
                print("\(j) , \(i)")
                print(playField[j].count)
                guard let targetBlock = nodes(at: playField[j][i]).first(where: {$0 is Block}) as? Block else {continue}
                if isSpotBelowOpen(block: targetBlock){
                    targetBlock.position.y -= targetBlock.frame.height
                }
            }
        }
    }
    func isSpotBelowOpen(block: Block) -> Bool{
        let occupancy = nodes(at: CGPoint(x: block.position.x, y: block.position.y - block.frame.height))
        //if the bspot below has a block return false
        if occupancy.contains(where: {$0 is Block}){
            return false
        }
        //if the spot below is below the bottom of the well return false
        if block.position.y - block.frame.height < stackBottomY{
            return false
        }
        return true
    }
    //MARK: Find Matches.
    func findMatches(block: Block, existingMatches: [Block]) -> [Block]{
        var matchFriends: [Block] = [block]
        for i in existingMatches{
            matchFriends.append(i)
        }
        let tileSize = block.frame.height
        let checkPoints: [CGPoint] = {
            let above = CGPoint(x: block.position.x, y: block.position.y + tileSize)
            let right = CGPoint(x: block.position.x + tileSize, y: block.position.y)
            let below = CGPoint(x: block.position.x, y: block.position.y - tileSize)
            let left = CGPoint(x:block.position.x - tileSize, y: block.position.y)
            return [above, right, below, left]
        }()
        //we're gonna check in 4 directions. If it finds a block of the same type, it'll add it to matchFriends, then run this function again with that new friend.
        //check above
        for i in 0...checkPoints.count - 1{
            let checkPoint = checkPoints[i]
            if nodes(at: checkPoint).contains(where: {$0 is Block}) && nodes(at: checkPoint).contains(where: {$0.name == block.name}){
                let newFriend = nodes(at: checkPoint).first(where: {$0.name == block.name}) as! Block //i can force here because i checked if its a block already
                if !matchFriends.contains(newFriend){
                    matchFriends.append(newFriend)
                    let evenMoreFriends = findMatches(block: newFriend, existingMatches: matchFriends)
                    for friend in evenMoreFriends{
                        if !matchFriends.contains(friend){
                            matchFriends.append(friend)
                        }
                    }
                }
            }
        }
        return matchFriends
    }
    
    //Now we just need a function thta calls "findMatches" on every block in the grid.
    func checkForMatches(){
        for i in 0...stackHeight - 1{ //row
            for j in 0...5{ //column
                guard let targetBlock = nodes(at: playField[j][i]).first(where: {$0 is Block}) as? Block else {continue}
                let matches = findMatches(block: targetBlock, existingMatches: [])
                    if matches.count >= 5{
                    for block in matches{
                        block.removeFromParent()
                    }
                }
            }
            stackGravity()
        }
    }
}
