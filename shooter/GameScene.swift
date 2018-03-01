import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let Player: UInt32 = 1
    static let Obstacle: UInt32 = 2
    static let Edge: UInt32 = 4
}

class GameScene: SKScene {

    let colors = [UIColor.yellow , UIColor.red , UIColor.purple, UIColor.green]
    let player = SKShapeNode(circleOfRadius: 10)
    var obstracles = [SKNode]()
    let obstracleSpacing: CGFloat = 400
    let cameraNode  = SKCameraNode()
    
    override func sceneDidLoad() {
        physicsWorld.contactDelegate = self
        }

    
    override func didMove(to view: SKView) {

        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
        setupPlayerAndObstacles()
        let playerBody = SKPhysicsBody(circleOfRadius: 5)
        playerBody.affectedByGravity = true
        playerBody.mass = 3
        playerBody.categoryBitMask = PhysicsCategory.Player
        playerBody.collisionBitMask = PhysicsCategory.Edge
        player.physicsBody = playerBody
        physicsWorld.gravity.dy = -10
        
       
        
        
    }
   
    func setupPlayerAndObstacles() {
        addObstacle()
        addObstacle()
        addObstacle()
        addPlayer()
    }
    func addPlayer(){
        player.position = CGPoint(x: size.width / 2, y: 50)
        player.fillColor = colors[2]
        player.strokeColor = colors[2]
        addChild(player)
        let ledge = SKNode()
        ledge.position = CGPoint(x: size.width/2, y: 20)
        let ledgeBody = SKPhysicsBody(rectangleOf: CGSize(width: 20, height: 10))
        ledgeBody.isDynamic = false
        ledgeBody.categoryBitMask = PhysicsCategory.Edge
        ledge.physicsBody = ledgeBody
        addChild(ledge)
        
    }
    func addObstacle() {
        addCircleObstacle()
    }
    
    func addCircleObstacle(){
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: -120))
        path.addLine(to: CGPoint(x: 0, y: -100))
        path.addArc(withCenter: CGPoint.zero,
                    radius: 100,
                    startAngle: CGFloat(3.0 * M_PI_2),
                    endAngle: CGFloat(0),
                    clockwise: true)
        path.addLine(to: CGPoint(x: 120, y: 0))
        path.addArc(withCenter: CGPoint.zero,
                    radius: 120,
                    startAngle: CGFloat(0.0),
                    endAngle: CGFloat(3.0 * M_PI_2),
                    clockwise: false)
      
        let CreatedCircle = obstacleByDuplicatingPath(path, clockwise: true)
        //CreatedCircle.position = CGPoint(x: size.width / 2 , y: size.height / 2)
        obstracles.append(CreatedCircle)
        CreatedCircle.position = CGPoint(x: size.width/2, y: obstracleSpacing *  (CGFloat(obstracles.count) > 0 ?  CGFloat(obstracles.count): size.height / (obstracleSpacing * 3 ) ))
        addChild(CreatedCircle)
        let rotateAction = SKAction.rotate(byAngle: CGFloat(2*Double.pi), duration: 6)
        CreatedCircle.run(SKAction.repeatForever(rotateAction))
    }
    
    func obstacleByDuplicatingPath(_ path: UIBezierPath, clockwise: Bool) -> SKNode{
        let container = SKNode()
        var rotationFactor = CGFloat(M_PI_2)
        if !clockwise{
            rotationFactor *= -1
            print("Rotation Factor :\(rotationFactor)")
        }
        for i in 0...3 {
            let section = SKShapeNode(path: path.cgPath)
            section.fillColor = colors[i]
            section.strokeColor = colors[i]
            section.zRotation = rotationFactor * CGFloat(i);
            //adding physics to the sections
            let physicsSection = SKPhysicsBody(polygonFrom: path.cgPath)
            physicsSection.affectedByGravity = false
            
            physicsSection.categoryBitMask = PhysicsCategory.Obstacle
            
            // as zero is not set to any category it will not collide with any object
            
            physicsSection.collisionBitMask = 0
            
            // test for contact with player object
            physicsSection.contactTestBitMask = PhysicsCategory.Player
            
            //not effected by gravity or by player
            physicsSection.isDynamic = false
            
            //adding physics to section
            section.physicsBody = physicsSection
            
            container.addChild(section)
        }
        return container
    }
    override func update(_ currentTime: TimeInterval) {
        cameraNode.position = player.position
    }
    
    func dieAndRestart() {
        print("boom")
        player.physicsBody?.velocity.dy = 0
        for node in obstracles{
            node.removeFromParent()
        }
        obstracles.removeAll()
        removeAllChildren()
        removeAllActions()
        setupPlayerAndObstacles()
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.physicsBody?.velocity.dy = 300.0
    }
    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
    
    
   
}
extension GameScene:SKPhysicsContactDelegate{
    
    func didBegin(_ contact: SKPhysicsContact) {
        if let body1 = contact.bodyA.node as? SKShapeNode, let body2 = contact.bodyB.node as? SKShapeNode{
            if body1.fillColor != body2.fillColor{
             dieAndRestart()
            }
        }
    }
    
}
