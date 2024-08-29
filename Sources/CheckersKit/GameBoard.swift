//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import SpriteKit

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
    
    // Player currently selecting a move.
    private var currentPlayer = PlayerColor.white
    // List of moves the player may choose from.
    private var moves = [Move]()
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
    
    public func addChecker(for player: PlayerColor, at position: CGPoint) {
        addChild(Checker(player: player, position: position))
    }
    
    public func addTarget(at position: CGPoint) {
        addChild(BoardTarget(position: position))
    }
    
    public func checker(at position: CGPoint) -> Checker? {
        atPoint(position) as? Checker
    }
    
    // Clears the board to start a new game.
    public func clear() {
        for child in children {
            if let checker = child as? Checker {
                checker.removeFromParent()
            }
        }
        deselectAll()
    }

    // Initiates move selection by the player.
    public func pickMove(
        for player: PlayerColor,
        moves: [Move],
        onMovePicked: @escaping OnMovePicked
    ) {
        self.currentPlayer = player
        self.moves = moves
        self.onMovePicked = onMovePicked
        
        // Do all moves originate with the same checker?
        guard let first = moves.first?.from else { return }
        guard moves.allSatisfy({ $0.from == first }) else { return }
        
        // Yes, so preselect that checker
        guard let checker = checker(at: first) else { return }
        onCheckerTouched(checker: checker)
    }
    
    // Handles a checker touched event.
    private func onCheckerTouched(checker: Checker) {
        // Touching the current selection, is a no-op.
        guard checker != selection else { return }
        
        // If the checker is selected (but isn't the selection), then it's really a target.
        guard !checker.selected else { return movePicked(to: checker.position) }
        
        // Ignore touches of the opponent's checkers.
        guard checker.player == currentPlayer else { return }
        
        // Clear the existing selection.
        deselectAll()
        
        // Get the moves for this checker only.
        let moves = moves.filter({ $0.from == checker.position })
        
        // If the checker has no moves available, there's nothing to do.
        guard !moves.isEmpty else { return }
        
        // Highlight the new selection
        selection = checker
        checker.selected = true
        
        // Highlight all the moves for the new selection.
        moves.forEach {
            let node = atPoint($0.to)
            if let checker = node as? Checker {
                checker.selected = true
                checker.threatened = true
            } else {
                (node as? BoardTarget)?.selected = true
            }
        }
    }
    
    // Handles atarget touched event. The target must be empty since checkers are at a higher
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
              let move = moves.first(where: {
                  $0 == Move(from: checker.position, to: to)
              }) else {
            return
        }
        
        // Clear the selection since the player's turn is over.
        deselectAll()
        
        // Stop accepting moves.
        self.moves = []
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
    
    // Dispatches touchDown events to the right handler.
    private func touchDown(location: CGPoint) {
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
