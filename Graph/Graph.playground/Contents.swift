//import Graph

//
//  AdjacencyListGraph.swift
//  Graph
//
//  Created by Andrew McKnight on 5/13/16.
//

import Foundation

//
//  Vertex.swift
//  Graph
//
//  Created by Andrew McKnight on 5/8/16.
//

//
//  Edge.swift
//  Graph
//
//  Created by Andrew McKnight on 5/8/16.
//

import Foundation

public struct Edge<T>: Equatable where T: Equatable, T: Hashable {
    
    public let from: Vertex<T>
    public let to: Vertex<T>
    
    public let weight: Double?
    
}

extension Edge: CustomStringConvertible {
    
    public var description: String {
        guard let unwrappedWeight = weight else {
            return "\(from.description) -> \(to.description)"
        }
        return "\(from.description) -(\(unwrappedWeight))-> \(to.description)"
    }
    
}

extension Edge: Hashable {
    
    public var hashValue: Int {
        var string = "\(from.description)\(to.description)"
        if weight != nil {
            string.append("\(weight!)")
        }
        return string.hashValue
    }
}

public func == <T>(lhs: Edge<T>, rhs: Edge<T>) -> Bool {
    guard lhs.from == rhs.from else {
        return false
    }
    
    guard lhs.to == rhs.to else {
        return false
    }
    
    guard lhs.weight == rhs.weight else {
        return false
    }
    
    return true
}


import Foundation

public struct Vertex<T>: Equatable where T: Equatable, T: Hashable {
    
    public var data: T
    public let index: Int
    
}

extension Vertex: CustomStringConvertible {
    
    public var description: String {
        return "\(index): \(data)"
    }
    
}

extension Vertex: Hashable {
    
    public var hashValue: Int {
        return "\(data)\(index)".hashValue
    }
    
}

public func ==<T: Equatable>(lhs: Vertex<T>, rhs: Vertex<T>) -> Bool {
    guard lhs.index == rhs.index else {
        return false
    }
    
    guard lhs.data == rhs.data else {
        return false
    }
    
    return true
}


private class EdgeList<T> where T: Equatable, T: Hashable {
    
    var vertex: Vertex<T>
    var edges: [Edge<T>]?
    
    init(vertex: Vertex<T>) {
        self.vertex = vertex
    }
    
    func addEdge(_ edge: Edge<T>) {
        edges?.append(edge)
    }
    
}

//
//  Graph.swift
//  Graph
//
//  Created by Andrew McKnight on 5/8/16.
//

import Foundation

open class AbstractGraph<T>: CustomStringConvertible where T: Equatable, T: Hashable {
    
    public required init() {}
    
    public required init(fromGraph graph: AbstractGraph<T>) {
        for edge in graph.edges {
            let from = createVertex(edge.from.data)
            let to = createVertex(edge.to.data)
            
            addDirectedEdge(from, to: to, withWeight: edge.weight)
        }
    }
    
    open var description: String {
        fatalError("abstract property accessed")
    }
    
    open var vertices: [Vertex<T>] {
        fatalError("abstract property accessed")
    }
    
    open var edges: [Edge<T>] {
        fatalError("abstract property accessed")
    }
    
    // Adds a new vertex to the matrix.
    // Performance: possibly O(n^2) because of the resizing of the matrix.
    open func createVertex(_ data: T) -> Vertex<T> {
        fatalError("abstract function called")
    }
    
    open func addDirectedEdge(_ from: Vertex<T>, to: Vertex<T>, withWeight weight: Double?) {
        fatalError("abstract function called")
    }
    
    open func addUndirectedEdge(_ vertices: (Vertex<T>, Vertex<T>), withWeight weight: Double?) {
        fatalError("abstract function called")
    }
    
    open func weightFrom(_ sourceVertex: Vertex<T>, to destinationVertex: Vertex<T>) -> Double? {
        fatalError("abstract function called")
    }
    
    open func edgesFrom(_ sourceVertex: Vertex<T>) -> [Edge<T>] {
        fatalError("abstract function called")
    }
}


open class AdjacencyListGraph<T>: AbstractGraph<T> where T: Equatable, T: Hashable {
    
    fileprivate var adjacencyList: [EdgeList<T>] = []
    
    public required init() {
        super.init()
    }
    
    public required init(fromGraph graph: AbstractGraph<T>) {
        super.init(fromGraph: graph)
    }
    
    open override var vertices: [Vertex<T>] {
        var vertices = [Vertex<T>]()
        for edgeList in adjacencyList {
            vertices.append(edgeList.vertex)
        }
        return vertices
    }
    
    open override var edges: [Edge<T>] {
        var allEdges = Set<Edge<T>>()
        for edgeList in adjacencyList {
            guard let edges = edgeList.edges else {
                continue
            }
            
            for edge in edges {
                allEdges.insert(edge)
            }
        }
        return Array(allEdges)
    }
    
    open override func createVertex(_ data: T) -> Vertex<T> {
        // check if the vertex already exists
        let matchingVertices = vertices.filter { vertex in
            return vertex.data == data
        }
        
        if matchingVertices.count > 0 {
            return matchingVertices.last!
        }
        
        // if the vertex doesn't exist, create a new one
        let vertex = Vertex(data: data, index: adjacencyList.count)
        adjacencyList.append(EdgeList(vertex: vertex))
        return vertex
    }
    
    open override func addDirectedEdge(_ from: Vertex<T>, to: Vertex<T>, withWeight weight: Double?) {
        // works
        let edge = Edge(from: from, to: to, weight: weight)
        let edgeList = adjacencyList[from.index]
        if edgeList.edges != nil {
            edgeList.addEdge(edge)
        } else {
            edgeList.edges = [edge]
        }
    }
    
    open override func addUndirectedEdge(_ vertices: (Vertex<T>, Vertex<T>), withWeight weight: Double?) {
        addDirectedEdge(vertices.0, to: vertices.1, withWeight: weight)
        addDirectedEdge(vertices.1, to: vertices.0, withWeight: weight)
    }
    
    open override func weightFrom(_ sourceVertex: Vertex<T>, to destinationVertex: Vertex<T>) -> Double? {
        guard let edges = adjacencyList[sourceVertex.index].edges else {
            return nil
        }
        
        for edge: Edge<T> in edges {
            if edge.to == destinationVertex {
                return edge.weight
            }
        }
        
        return nil
    }
    
    open override func edgesFrom(_ sourceVertex: Vertex<T>) -> [Edge<T>] {
        return adjacencyList[sourceVertex.index].edges ?? []
    }
    
    open override var description: String {
        var rows = [String]()
        for edgeList in adjacencyList {
            
            guard let edges = edgeList.edges else {
                continue
            }
            
            var row = [String]()
            for edge in edges {
                var value = "\(edge.to.data)"
                if edge.weight != nil {
                    value = "(\(value): \(edge.weight!))"
                }
                row.append(value)
            }
            
            rows.append("\(edgeList.vertex.data) -> [\(row.joined(separator: ", "))]")
        }
        
        return rows.joined(separator: "\n")
    }
}

//
//  AdjacencyMatrixGraph.swift
//  Graph
//
//  Created by Andrew McKnight on 5/13/16.
//

import Foundation

open class AdjacencyMatrixGraph<T>: AbstractGraph<T> where T: Equatable, T: Hashable {
    
    // If adjacencyMatrix[i][j] is not nil, then there is an edge from
    // vertex i to vertex j.
    fileprivate var adjacencyMatrix: [[Double?]] = []
    fileprivate var _vertices: [Vertex<T>] = []
    
    public required init() {
        super.init()
    }
    
    public required init(fromGraph graph: AbstractGraph<T>) {
        super.init(fromGraph: graph)
    }
    
    open override var vertices: [Vertex<T>] {
        return _vertices
    }
    
    open override var edges: [Edge<T>] {
        var edges = [Edge<T>]()
        for row in 0 ..< adjacencyMatrix.count {
            for column in 0 ..< adjacencyMatrix.count {
                if let weight = adjacencyMatrix[row][column] {
                    edges.append(Edge(from: vertices[row], to: vertices[column], weight: weight))
                }
            }
        }
        return edges
    }
    
    // Adds a new vertex to the matrix.
    // Performance: possibly O(n^2) because of the resizing of the matrix.
    open override func createVertex(_ data: T) -> Vertex<T> {
        // check if the vertex already exists
        let matchingVertices = vertices.filter { vertex in
            return vertex.data == data
        }
        
        if matchingVertices.count > 0 {
            return matchingVertices.last!
        }
        
        // if the vertex doesn't exist, create a new one
        let vertex = Vertex(data: data, index: adjacencyMatrix.count)
        
        // Expand each existing row to the right one column.
        for i in 0 ..< adjacencyMatrix.count {
            adjacencyMatrix[i].append(nil)
        }
        
        // Add one new row at the bottom.
        let newRow = [Double?](repeating: nil, count: adjacencyMatrix.count + 1)
        adjacencyMatrix.append(newRow)
        
        _vertices.append(vertex)
        
        return vertex
    }
    
    open override func addDirectedEdge(_ from: Vertex<T>, to: Vertex<T>, withWeight weight: Double?) {
        adjacencyMatrix[from.index][to.index] = weight
    }
    
    open override func addUndirectedEdge(_ vertices: (Vertex<T>, Vertex<T>), withWeight weight: Double?) {
        addDirectedEdge(vertices.0, to: vertices.1, withWeight: weight)
        addDirectedEdge(vertices.1, to: vertices.0, withWeight: weight)
    }
    
    open override func weightFrom(_ sourceVertex: Vertex<T>, to destinationVertex: Vertex<T>) -> Double? {
        return adjacencyMatrix[sourceVertex.index][destinationVertex.index]
    }
    
    open override func edgesFrom(_ sourceVertex: Vertex<T>) -> [Edge<T>] {
        var outEdges = [Edge<T>]()
        let fromIndex = sourceVertex.index
        for column in 0..<adjacencyMatrix.count {
            if let weight = adjacencyMatrix[fromIndex][column] {
                outEdges.append(Edge(from: sourceVertex, to: vertices[column], weight: weight))
            }
        }
        return outEdges
    }
    
    open override var description: String {
        var grid = [String]()
        let n = self.adjacencyMatrix.count
        for i in 0..<n {
            var row = ""
            for j in 0..<n {
                if let value = self.adjacencyMatrix[i][j] {
                    let number = NSString(format: "%.1f", value)
                    row += "\(value >= 0 ? " " : "")\(number) "
                } else {
                    row += "  ø  "
                }
            }
            grid.append(row)
        }
        return (grid as NSArray).componentsJoined(by: "\n")
    }
    
}


for graph in [AdjacencyMatrixGraph<Int>(), AdjacencyListGraph<Int>()] {

//  let v1 = graph.createVertex(1)
//  let v2 = graph.createVertex(2)
//  let v3 = graph.createVertex(3)
//  let v4 = graph.createVertex(4)
//  let v5 = graph.createVertex(5)
//
//  // Set up a cycle like so:
//  //               v5
//  //                ^
//  //                | (3.2)
//  //                |
//  // v1 ---(1)---> v2 ---(1)---> v3 ---(4.5)---> v4
//  // ^                                            |
//  // |                                            V
//  // ---------<-----------<---------(2.8)----<----|
//
//  graph.addDirectedEdge(v1, to: v2, withWeight: 1.0)
//  graph.addDirectedEdge(v2, to: v3, withWeight: 1.0)
//  graph.addDirectedEdge(v3, to: v4, withWeight: 4.5)
//  graph.addDirectedEdge(v4, to: v1, withWeight: 2.8)
//  graph.addDirectedEdge(v2, to: v5, withWeight: 3.2)
//
//  // Returns the weight of the edge from v1 to v2 (1.0)
//  graph.weightFrom(v1, to: v2)
//
//  // Returns the weight of the edge from v1 to v3 (nil, since there is not an edge)
//  graph.weightFrom(v1, to: v3)
//
//  // Returns the weight of the edge from v3 to v4 (4.5)
//  graph.weightFrom(v3, to: v4)
//
//  // Returns the weight of the edge from v4 to v1 (2.8)
//  graph.weightFrom(v4, to: v1)
//
//  print(graph)
//  print() // separate by a newline
}

var graph = AdjacencyListGraph<Int>()

let v1 = graph.createVertex(1)
let v2 = graph.createVertex(2)
let v3 = graph.createVertex(3)
let v4 = graph.createVertex(4)
let v5 = graph.createVertex(5)

graph.addDirectedEdge(v1, to: v2, withWeight: 10.0)
graph.addDirectedEdge(v2, to: v3, withWeight: 2.0)
graph.addDirectedEdge(v3, to: v5, withWeight: 3.0)
graph.addDirectedEdge(v1, to: v4, withWeight: 3.0)
graph.addDirectedEdge(v4, to: v5, withWeight: 100.0)

print(graph)
