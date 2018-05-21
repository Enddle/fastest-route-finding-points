import QuartzCore

let start = CACurrentMediaTime()

class Point {
    
    public var val: Int
    
    public var pos: [Int]
    
    public var id: Int
    
    init(_ value: Int, _ position: [Int]) {
        
        self.val = value
        self.pos = position
        self.id = -1
    }
    
    func setId(_ id: Int) {
        
        self.id = id
    }
    
    func distance(_ from: [Int]) -> Int {
        
        return abs(from[0] - self.pos[0]) + abs(from[1] - self.pos[1])
    }
    
    func time(_ from: [Int], _ speed: Int) -> Double {
        
        return Double(distance(from)) / Double(speed)
    }
}


extension Dictionary where Value: Equatable {
    /// Returns all keys mapped to the specified value.
    func keysForValue(value: Value) -> [Key] {
        return compactMap { (key: Key, val: Value) -> Key? in
            value == val ? key : nil
        }
    }
}



//`````````````````````````
//        ENV INIT
//_________________________


let points: [Point] = [  // all points
    Point(3, [2, 1]),
    Point(2, [2, 3]),
    Point(1, [3, 4]),
    Point(1, [4, 2]),
    Point(2, [4, 0]),

    //  Using the points in the bottom-left 5 x 5 boxes for testing
    
//    Point(1, [7, 0]),
//    Point(3, [6, 2]),
//    Point(2, [6, 4]),
//    Point(1, [6, 6]),
//    Point(2, [7, 7]),
//    Point(3, [4, 6]),
//    Point(2, [2, 7]),
//    Point(1, [0, 7]),
//    Point(1, [1, 5]),
]

var map = [Int: Point]()  // put points in map with id

var id = 0
for point in points {

    map[id] = point
    id += 1
}



//`````````````````````````
//       LOOP CODES
//_________________________


// global variables

var diss = [Int: Int]()
var times = [Int: Double]()
var seqs = [Int: [Int]]()
var cal = 0


// in-loop variables

var inpos = [0,0]
var inseq: [Int] = []
var indis = 0
var intime = 0.0


func loop(_ t: Int, _ seq: [Int], _ pos: [Int], dis: Int) {  // #4
    
    if cal >= maxCal {  // terminate when get to maximum calculate times
        return
    }
    
    if t == points.count - 1 {  // save result and terminate when loops for ONE route finished
        cal += 1
        diss[diss.count] = indis
        seqs[seqs.count] = inseq
        return
    }
    
    for (pointId, point) in map {
        
        // get looping variables
        
        inseq = seq
        inpos = pos
        indis = dis
        
        if inseq.contains(pointId) {  // route already passed this point
            continue
        }
        
        // move to this point
        
        inseq.append(pointId)
        indis += point.distance(inpos)
        inpos = point.pos
        
        if t == points.count - 2 {  // if only one route left
            
            // using id sums to calculate last point id
            let lastId = (1...points.count-1).map{$0}.reduce(0, +) - inseq.reduce(0, +)
            
            // move to last point
            
            inseq.append(lastId)
            indis += (map[lastId]?.distance(inpos))!
            inpos = (map[lastId]?.pos)!
        }
        
        loop(t + 1, inseq, inpos, dis: indis)  // entering next loop
    }
}


func loop(_ t: Int, _ seq: [Int], _ pos: [Int], time: Double, _ speed: Int = 1) {  // #5
    
    if cal >= maxCal {
        return
    }
    
    if t == points.count - 1 {
        cal += 1
        times[times.count] = intime
        seqs[seqs.count] = inseq
        return
    }
    
    for (pointId, point) in map {
        
        inseq = seq
        inpos = pos
        intime = time
        
        if inseq.contains(pointId) {
            continue
        }
        
        inseq.append(pointId)
        intime += point.time(inpos, speed)
        inpos = point.pos
        
        if t == points.count - 2 {
            
            let lastId = (1...points.count-1).map{$0}.reduce(0, +) - inseq.reduce(0, +)
            
            inseq.append(lastId)
            intime += (map[lastId]?.time(inpos, point.val))!
            inpos = (map[lastId]?.pos)!
        }
        
        loop(t + 1, inseq, inpos, time: intime, point.val)
    }
}


func showResults() {  // basic information
    
    let execTime = ((CACurrentMediaTime() - start) * 100).rounded() / 100
    
    if cal < maxCal {
        
        print("  Completed!", terminator: "")
    }
    
    print("  \(cal) routes calculated in \(execTime) sec.\n")
}

func showResults(_ dic : Dictionary<Int, Int>) {  // #4
    
    showResults()
    
    for keyId in dic.keysForValue(value: dic.values.min()!) {
        
        print("  Shortest route(s) in \(dic.values.min() ?? -1) steps: \n  ", terminator: "")
        for pointId in seqs[keyId]! {
            print("  \(map[pointId]?.pos ?? [])", terminator: "")
        }
        print("\n")
    }
}

func showResults(_ dic : Dictionary<Int, Double>) {  // #5
    
    showResults()
    
    for keyId in dic.keysForValue(value: dic.values.min()!) {
        
        print("  Shortest route(s) in \(dic.values.min() ?? -1) seconds: \n  ", terminator: "")
        for pointId in seqs[keyId]! {
            print("  \(map[pointId]?.pos ?? [])", terminator: "")
        }
        print("\n")
    }
}



//`````````````````````````
//        TESTING
//_________________________


let maxCal = 200  // limiting the max counts of result calculated

// for #4

//loop(0, inseq, inpos, dis: indis)
//showResults(diss)

// for #5

loop(0, inseq, inpos, time: intime)
showResults(times)





