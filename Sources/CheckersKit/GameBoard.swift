//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import SpriteKit

public class GameBoard: SKSpriteNode {
    public struct Move: Equatable {
        let from: CGPoint
        let to: CGPoint
    }
    public typealias OnMoveSelected = (Int) -> Void
    
    private let onMoveSelected: OnMoveSelected
    private var allowedMoves = [Move]()
    private var selected: Checker? = nil
    
    public override var isUserInteractionEnabled: Bool {
        get { true }
        set { }
    }
    
    private var acceptInput: Bool { !allowedMoves.isEmpty }
    
    
    public init(onMoveSelected: @escaping OnMoveSelected) {
        self.onMoveSelected = onMoveSelected
        let texture = SKTexture(imageNamed: "gameboard")
        super.init(texture: texture, color: .clear, size: texture.size())
        self.zPosition = Layer.gameboard
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addCheckers(for player: PlayerColor, positions: [CGPoint]) {
        positions.forEach { addChild(Checker(player: player, position: $0)) }
    }
    
    public func addTargets(positions: [CGPoint]) {
        positions.forEach { addChild(BoardTarget(position: $0)) }
    }
    
    private func onCheckerTouched(checker: Checker) {
        // If he touched the the piece that's already selected, it's a no-op.
        guard checker != selected else {
            return
        }
        
        // If the checker is both selected && threatened, then it's really a target.
        guard checker.selected && checker.threatened else {
            moveSelected(to: checker.position)
            return
        }
        
        // Clear the existing selection.
        deselectAll()
        
        // Highlight the new selection
        selected = checker
        checker.selected = true
        
        // Highlight all the moves for the new selection.
        allowedMoves.filter({ $0.from == checker.position }).forEach {
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
        let from = selected?.position ?? .init()
        
        // Clear the selection since the player's turn is over.
        deselectAll()
        
        // Stop accepting moves.
        allowedMoves = []
        
        // Process the move.
        let index = allowedMoves.firstIndex(of: Move(from: from, to: to)) ?? 0
        onMoveSelected(index)
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
        selected = nil
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
