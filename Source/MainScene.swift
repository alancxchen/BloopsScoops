import Foundation

class MainScene: CCNode {
    
    
    
    
    
    func didLoadFromCCB() {
        userInteractionEnabled = true
        
    }
    func play() {
        
        let gamePlayScene = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().presentScene(gamePlayScene)
        
    }
    
    
}
