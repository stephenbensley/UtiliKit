//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import SpriteKit

public class GameBoard: SKSpriteNode {
    public struct Move: Equatable {
        public let from: CGPoint
        public let to: CGPoint
        
        public init(from: CGPoint, to: CGPoint) {
            self.from = from
            self.to = to
        }
    }
    
    public typealias OnMoveSelected = (Int) -> Void
    
    private var player = PlayerColor.white
    private var moves = [Move]()
    private var onMoveSelected: OnMoveSelected? = nil
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
    
    public func selectMove(
        for player: PlayerColor,
        moves: [Move],
        onMoveSelected: @escaping OnMoveSelected
    ) {
        self.player = player
        self.moves = moves
        self.onMoveSelected = onMoveSelected
        
        // Do all moves originate with the same checker?
        guard let first = moves.first?.from else { return }
        guard moves.allSatisfy({ $0.from == first }) else { return }
        
        // Yes, so preselect that checker
        guard let checker = atPoint(first) as? Checker else { return }
        onCheckerTouched(checker: checker)
    }
    
    private func onCheckerTouched(checker: Checker) {
        // Touching the current selection, is a no-op.
        guard checker != selection else {
            return
        }
        
        // Is it the opponent's checker?
        if checker.player != player {
            // If the checker is selected, then it's really a target. Otherwise, just ignore.
            if checker.selected {
                moveSelected(to: checker.position)
            }
            return
        }
        
        // Clear the existing selection.
        deselectAll()
        
        // Get the moves for this checker only.
        let moves = moves.filter({ $0.from == checker.position })
        
        // If the checker has no moves available, there's nothing to do.
        guard !moves.isEmpty else {
            return
        }
        
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
    
    private func onTargetTouched(target: BoardTarget) {
        // Check if this is a legal move.
        guard target.selected else {
            return
        }
        moveSelected(to: target.position)
    }
    
    private func moveSelected(to: CGPoint) {
        // Guaranteed to be set since a move has been selected.
        let from = selection?.position ?? .init()
        
        // Clear the selection since the player's turn is over.
        deselectAll()
        
        // Save the info we need to dispatch the completion notification
        let onMoveSelected = self.onMoveSelected
        let index = moves.firstIndex(of: Move(from: from, to: to)) ?? 0
        
        // Stop accepting moves.
        self.moves = []
        self.onMoveSelected = nil
        
        onMoveSelected?(index)
    }
    
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
