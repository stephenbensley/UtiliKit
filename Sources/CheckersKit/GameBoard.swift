//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import SpriteKit
import UtiliKit

// The gameboard which the checkers move around.
public class GameBoard: SKSpriteNode {
    // A move on the board.
    public struct Move: Equatable {
        public let from: CGPoint
        public let to: CGPoint
        public let userData: Any
        
        public init(from: CGPoint, to: CGPoint, userData: Any = 0) {
            self.from = from
            self.to = to
            self.userData = userData
        }
        
        public static func == (lhs: Move, rhs: Move) -> Bool {
            (lhs.from == rhs.from) && (lhs.to == rhs.to)
        }
    }
    
    // Used to signal that the user has picked a move.
    public typealias OnMovePicked = (Checker, Move) -> Void
    
    // Can be used to temporarily disable input.
    public var inputEnabled = true
    // Player currently selecting a move.
    private var currentPlayer = PlayerColor.white
    // List of moves the player may choose from.
    private var allowedMoves = [Move]()
    // Callback invoked when the user has made a selection
    private var onMovePicked: OnMovePicked? = nil
    // Currently selected checker, if any. This is the source of the move.
    private var selection: Checker? = nil
    
    public override var isUserInteractionEnabled: Bool {
        get { true }
        set { }
    }
    
    public init() {
        let texture = SKTexture(imageNamed: "gameboard")
        super.init(texture: texture, color: .clear, size: texture.size())
        self.zPosition = Layer.gameboard
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func checker(at position: CGPoint) -> Checker? {
        atPoint(position) as? Checker
    }
    
    // Clears the board to start a new game.
    public func clear() {
        for child in children where child is Checker || child.name == AutoAlert.nodeName {
            child.removeFromParent()
            
        }
        deselectAll()
    }
    
    // Displays the outcome of the game as a banner at the top of the screen.
    public func displayOutcome(text: String) {
        // First display an alert to get the user's attention.
        let alert = AutoAlert(text)
        addChild(alert)
        alert.display(forDuration: 3.0, completion: { })
        
        // Then add a permanent banner.
        let text = SKLabelNode(text: text)
        text.alpha = 0.0
        // Keep the appearance consistent with the alert.
        text.fontName = AutoAlert.fontName
        text.fontSize = AutoAlert.fontSize * 1.2
        text.name = AutoAlert.nodeName
        // Position it just above the game board.
        text.position = .init(x: 0.0, y: 0.5 * size.height + 30.0)
        text.verticalAlignmentMode = .center
        addChild(text)
        
        text.run(SKAction.sequence([
            SKAction.wait(forDuration: 3.4),
            SKAction.fadeIn(withDuration: 0.3)
        ]))
    }
    
    // Initiates move selection by the player.
    public func pickMove(
        for player: PlayerColor,
        allowedMoves: [Move],
        onMovePicked: @escaping OnMovePicked
    ) {
        self.currentPlayer = player
        self.allowedMoves = allowedMoves
        self.onMovePicked = onMovePicked
        
        // Do all moves originate with the same checker?
        guard let first = allowedMoves.first?.from else { return }
        guard allowedMoves.allSatisfy({ $0.from == first }) else { return }
        
        // Yes, so preselect that checker
        guard let checker = checker(at: first) else { return }
        onCheckerTouched(checker: checker)
    }
    
    // Selects a specific move -- useful for giving the player hints.
    public func selectMove(_ move: Move) {
        guard let checker = checker(at: move.from) else { return }
        
        deselectAll()
        
        // Highlight the new selection
        selection = checker
        checker.selected = true
        
        selectDestination(at: move.to)
    }
    
    // Handles a checker touched event.
    private func onCheckerTouched(checker: Checker) {
        // If the checker is selected (but isn't the selection), then it's really a target.
        if checker.selected && checker != selection { return movePicked(to: checker.position) }
        
        // Ignore touches of the opponent's checkers.
        guard checker.player == currentPlayer else { return }
        
        // Clear the existing selection.
        deselectAll()
        
        // Get the moves for this checker only.
        let moves = allowedMoves.filter({ $0.from ~= checker.position })
        
        // If the checker has no moves available, there's nothing to do.
        guard !moves.isEmpty else { return }
        
        // Highlight the new selection
        selection = checker
        checker.selected = true
        
        // Highlight all the moves for the new selection.
        moves.forEach { selectDestination(at: $0.to) }
    }
    
    // Handles a target touched event. The target must be empty since checkers are at a higher
    // zPosition and would have gotten the touch instead.
    private func onTargetTouched(target: BoardTarget) {
        // Check if this is a legal move.
        guard target.selected else { return }
        movePicked(to: target.position)
    }
    
    // Called when the user has made a valid move selection.
    private func movePicked(to: CGPoint) {
        // Make sure we have everything we need to dispatch the completion.
        guard let onMovePicked = onMovePicked,
              let checker = selection,
              let move = allowedMoves.first(where: {
                  ($0.from ~= checker.position) && ($0.to ~= to)
              }) else {
            return
        }
        
        // Clear the selection since the player's turn is over.
        deselectAll()
        
        // Stop accepting moves.
        self.allowedMoves = []
        self.onMovePicked = nil
        
        // Notify the client.
        onMovePicked(checker, move)
    }
    
    // Deslect all items on the gameboard, checkers and targets.
    private func deselectAll() {
        for child in children {
            if let checker = child as? Checker {
                checker.selected = false
                checker.threatened = false
            } else {
                (child as? BoardTarget)?.selected = false
            }
        }
        selection = nil
    }
    
    // Select a move destination -- could be another checker or an empty target.
    private func selectDestination(at position: CGPoint) {
        let node = atPoint(position)
        if let checker = node as? Checker {
            checker.selected = true
            checker.threatened = true
        } else {
            (node as? BoardTarget)?.selected = true
        }
    }
    
    // Dispatches touchDown events to the right handler.
    private func touchDown(location: CGPoint) {
        guard inputEnabled else { return }
        
        let node = atPoint(location)
        if let checker = node as? Checker {
            onCheckerTouched(checker: checker)
        } else if let target = node as? BoardTarget {
            onTargetTouched(target: target)
        }
    }
    
#if os(macOS)
    public override func mouseDown(with event: NSEvent) {
        touchDown(location: event.location(in: self))
    }
#else
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(location: t.location(in: self))}
    }
#endif
}
