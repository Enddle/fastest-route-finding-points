import QuartzCore
import Darwin

let start = CACurrentMediaTime()

enum RunMode {
    
    case DistanceBased
    
    case TimeBased
}

class Point {
    
    public var val: Int
    
    public var pos: [Int]
    
    init(_ value: Int, _ position: [Int]) {
        
        self.val = value
        self.pos = position
    }

    func distance(_ from: [Int]) -> Int {

        return abs(from[0] - self.pos[0]) + abs(from[1] - self.pos[1])
    }
    
    func time(_ from: [Int], _ speed: Int) -> Double {
        
        return Double(distance(from)) / Double(speed)
    }
}

class AstarListPoint {
    
    public var point: Point
    
    public var step: Double
    
    public var valueG: Double
    
    public var valueH: Double
    
    public var valueF: Double
    
    public var parent: AstarListPoint?
    
    init(_ point: Point) {
        
        self.point = point
        
        self.step = 0
        
        self.valueG = 0
        self.valueH = Double(points.count) * valueHMultiplier
        
        self.valueF = valueG + valueH
    }
    
    init(_ point: Point, parent: AstarListPoint, mode: RunMode) {
        
        self.point = point
        self.parent = parent
        
        switch mode {
        
        case .DistanceBased:
            
            self.step = Double(point.distance(parent.point.pos))
            
        case .TimeBased:
            
            self.step = round(point.time(parent.point.pos, parent.point.val), n: 2)
        }
        
        self.valueG = parent.valueG + step
        self.valueH = parent.valueH - valueHMultiplier
        
        self.valueF = valueG + valueH
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
    Point(1, [7, 0]),
    Point(3, [6, 2]),
    Point(2, [6, 4]),
    Point(1, [6, 6]),
    Point(2, [7, 7]),
    Point(3, [4, 6]),
    Point(2, [2, 7]),
    Point(1, [0, 7]),
    Point(1, [1, 5]),
]


func round(_ d: Double, n: Int) -> Double {
    
    if (d.truncatingRemainder(dividingBy: 1) == 0) { return d }
    
    let p = (pow(10, n) as NSDecimalNumber).doubleValue
    
    return round(d * p) / p
}



//`````````````````````````
//       LOOP CODES
//_________________________


func isVisited(_ pos:[Int], _ v: [AstarListPoint]) -> Bool {
    
    for aslPoint in v {
        
        if aslPoint.point.pos == pos { return true }
    }
    return false
}


func getMinList(_ depth: Int, min: [Double], input: [AstarListPoint], output: [AstarListPoint] = []) -> [AstarListPoint] {
    
    let prevF = (depth > 0) ? min[0] : 0
    
    var minF = (depth > 0) ? min[1] : min[0]
    
    var nextF = minF
    
    var minList: [AstarListPoint] = []

    for aslPoint in input {
        
        let f = aslPoint.valueF
        
        if f <= prevF { continue }  // pass when smaller than previous min
        
        
        
        if f > nextF { continue }  // pass when current > next min
        
        else if f < nextF { nextF = f }  // update next min when current < next min
        
        
        
        if f > minF { continue }  // pass when current > min
        
        else if f < minF {  // update mins and clear list when current < min
            nextF = minF
            minF = f
            minList = []
        }
        
        minList.append(aslPoint)  // append when current <= min
    }
    
    minList.append(contentsOf: output)
    
    if (depth + 1) > greedyDepth { return minList }
    
    else {
        return getMinList(depth + 1, min: [minF, nextF], input: input, output: minList)
    }
}


func loopAstar(_ v: [AstarListPoint], mode: RunMode) {
    
    var visiting: [AstarListPoint] = []
    
    if cals >= maxCal { showEnd() }  // Safety control
    
    for pt in points {
        
        if isVisited(pt.pos, v) { continue }  // pass visited points
        
        visiting.append(AstarListPoint(pt, parent: v.last!, mode: mode))  // add to visiting queue
    }
    
    if visiting.count < 1 { return }  // out loop when no points left
    
    if !disableAstar {
        
        let a = visiting.count
        
        visiting = getMinList(0, min: [visiting.first!.valueF], input: visiting)  // filter queue by A* F value
        
        filtered += (a - visiting.count)
    }
        
    for aslPoint in visiting {
        
        // filter by value G
        if aslPoint.valueG > valueGTres { filtered += 1; continue }
        
        // filter by value G with anicipated step
        if aslPoint.valueG + (aslPoint.valueH / valueHMultiplier * smallestStepTres) > valueGTres { filtered += 1; continue }
        
        // filter by largest single step
        if aslPoint.step > largestStepTres { filtered += 1; continue }
        
        
            // Add this point to a temperarory visited queue and start a new loop branch
        
        var branchV = v
        branchV.append(aslPoint)
        
        if branchV.last!.valueH == 0 {  // out loop when finish
            
            // filter by value G
            if branchV.last!.valueG > valueGTres { filtered += 1; return }
            
            showResults(branchV)
            
            branchV = []
            
            continue
        }
        cals += 1
        loopAstar(branchV, mode: mode)
    }
}

func showResults(_ v: [AstarListPoint] = visited) {
    
    routes += 1
    
    print("pos \t\t\t G \t\t\t H \t\t\t F \t\t\t parent\n")

    for aslPoint in v {
        print("\(aslPoint.point.pos) \t\t \(aslPoint.valueG) \t\t \(aslPoint.valueH) \t\t \(aslPoint.valueF) \t\t \(aslPoint.parent?.point.pos ?? [])")
    }
    
    print("\n\n")
    
    // compare this route with the best route
    
    if (best == nil) { best = v.last!.valueG }
    
    else if (v.last!.valueG > best!) { return }
    
    else if (v.last!.valueG < best!) {
        
        best = v.last!.valueG
        bestRoutes = []
    }
    
    bestRoutes.append(v)
}

func showEnd() {
    
    let execTime = round((CACurrentMediaTime() - start), n: 3)

    if cals < maxCal {

        print("\tCompleted!", terminator: "")
    }

    print("\t\(routes) routes with \(cals) calculations in \(execTime) sec.  \(filtered) or more are filtered\n\n")
    
    
    if (best != nil) { showAnswer() }  // print answer
    
    exit(0)
}

func showAnswer() {
    
    print("\n/////////////////////////////// ANSWER ////////////////////////////////\n//")
    
    print("//\tFastest route\(bestRoutes.count > 1 ? "s cost" : " costs") around \(best!) seconds. Listed below: \n//")
    
    var i = 1
    
    for route in bestRoutes {
        
        print("//  (\(i))\t  ", terminator: "")
        
        for aslPoint in route {
            print("\(aslPoint.point.pos)", terminator: "  ")
        }
        print("\n//")
        
        i += 1
    }
    
    print("///////////////////////////////////////////////////////////////////////\n")
}

func configure(mode: RunMode) {
    
    let configs: [[Double]] = [config_4, config_5]
    
    let m = (mode == .DistanceBased) ? 0 : 1
    
    valueGTres =       configs[m][0]
    smallestStepTres = configs[m][1]
    largestStepTres =  configs[m][2]
}

func start(visited: [AstarListPoint], mode: RunMode) {
    
    configure(mode: mode)
    
    loopAstar(visited, mode: mode)

    showEnd()
}



//`````````````````````````
//        TESTING
//_________________________


    // Variable declarations

var cals = 0, filtered = 0, routes = 0

var visited: [AstarListPoint] = []

var valueGTres: Double, smallestStepTres: Double, largestStepTres: Double

var best: Double?, bestRoutes: [[AstarListPoint]] = []


    // General configurations

let mode: RunMode = .TimeBased  // question #4 or #5

let maxCal = 1000  // limiting the max counts of result calculated

let disableAstar = false  // disable A*

let greedyDepth = 8  // additional searching depth in A*

let valueHMultiplier = Double(1)  // adjust ratio of H in F value in A*

visited = [AstarListPoint(Point(1, [0, 0]))]  // starting point

//visited.append(AstarListPoint(points[0], parent: visited[0], mode: mode))  // Route predictions, uncomment for less calculations
//visited.append(AstarListPoint(points[1], parent: visited[1], mode: mode))


    // Question specific configs

    //           max G value      anticipated smallest step     max single step
    //           Small - LESS     Large - LESS                  Small - LESS
    // conf #4 [ 36.0,            2.0,                          12.0            ]
    // conf #5 [ 24.5,            0.0,                          4.0             ]

let config_4 = [ 35.0,            2.0,                          5.0             ]
let config_5 = [ 24.5,            1.0,                          3.0             ]


    // Run

start(visited: visited, mode: mode)
