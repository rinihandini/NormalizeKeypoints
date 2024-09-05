import Foundation
import PlaygroundSupport

// Keypoint structure for 3D coordinates
struct Keypoint3D: Decodable {
    var id: Int?
    var keypoints: [CGFloat]
}

// Load JSON data
func loadJSON(from fileName: String) -> [Keypoint3D]? {
    if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let keypointsData = try decoder.decode([Keypoint3D].self, from: data)
            return keypointsData
        } catch {
            print("Error loading JSON from \(fileName): \(error)")
            return nil
        }
    }
    print("Failed to locate JSON file \(fileName).")
    return nil
}

// Load keypoints from multiple files
let twKeypointsData = loadJSON(from: "TW_Keypoints") ?? []
let caKeypointsData = loadJSON(from: "CA_Keypoints") ?? []

// Combine all datasets
let allKeypointsData = twKeypointsData + caKeypointsData

// Extract x, y, z coordinates into separate arrays
let allXValues = allKeypointsData.compactMap { $0.keypoints.indices.contains(0) ? $0.keypoints[0] : nil }
let allYValues = allKeypointsData.compactMap { $0.keypoints.indices.contains(1) ? $0.keypoints[1] : nil }
let allZValues = allKeypointsData.compactMap { $0.keypoints.indices.contains(2) ? $0.keypoints[2] : nil }

// Compute global min and max for each dimension
let globalMinX = allXValues.min() ?? 0
let globalMaxX = allXValues.max() ?? 1
let globalMinY = allYValues.min() ?? 0
let globalMaxY = allYValues.max() ?? 1
let globalMinZ = allZValues.min() ?? 0
let globalMaxZ = allZValues.max() ?? 1

// Compute range for each dimension
let globalRangeX = globalMaxX - globalMinX
let globalRangeY = globalMaxY - globalMinY
let globalRangeZ = globalMaxZ - globalMinZ

print("Global Min X: \(globalMinX), Global Max X: \(globalMaxX), Global Range X: \(globalRangeX)")
print("Global Min Y: \(globalMinY), Global Max Y: \(globalMaxY), Global Range Y: \(globalRangeY)")
print("Global Min Z: \(globalMinZ), Global Max Z: \(globalMaxZ), Global Range Z: \(globalRangeZ)")

// Function Normalize 3D keypoint
// Formula: normalized = (original_value - min_value) / range * scale
func normalizeKeypoint3D(_ keypoint: Keypoint3D, globalMinX: CGFloat, globalRangeX: CGFloat, globalMinY: CGFloat, globalRangeY: CGFloat, globalMinZ: CGFloat, globalRangeZ: CGFloat, toSize size: CGSize) -> Keypoint3D {
    
    guard globalRangeX > 0, globalRangeY > 0, globalRangeZ > 0 else { return keypoint }
    
    let scaleX = min(size.width, size.height) / globalRangeX
    let scaleY = min(size.width, size.height) / globalRangeY
    let scaleZ = min(size.width, size.height) / globalRangeZ
    
    let normalizedX = (keypoint.keypoints[0] - globalMinX) * scaleX
    let normalizedY = (keypoint.keypoints[1] - globalMinY) * scaleY
    let normalizedZ = (keypoint.keypoints[2] - globalMinZ) * scaleZ
    return Keypoint3D(id: keypoint.id, keypoints: [normalizedX, normalizedY, normalizedZ])
}

// Normalize keypoints and print results
print("\nNormalized Keypoints for TW_Keypoints:")
for keypoint in twKeypointsData.prefix(10) {
    let normalizedKeypoint = normalizeKeypoint3D(keypoint, globalMinX: globalMinX, globalRangeX: globalRangeX, globalMinY: globalMinY, globalRangeY: globalRangeY, globalMinZ: globalMinZ, globalRangeZ: globalRangeZ, toSize: CGSize(width: 100, height: 100))
    print("Original: \(keypoint.keypoints), Normalized: \(normalizedKeypoint.keypoints)")
}

print("\nNormalized Keypoints for CA_Keypoints:")
for keypoint in caKeypointsData.prefix(10) {
    let normalizedKeypoint = normalizeKeypoint3D(keypoint, globalMinX: globalMinX, globalRangeX: globalRangeX, globalMinY: globalMinY, globalRangeY: globalRangeY, globalMinZ: globalMinZ, globalRangeZ: globalRangeZ, toSize: CGSize(width: 100, height: 100))
    print("Original: \(keypoint.keypoints), Normalized: \(normalizedKeypoint.keypoints)")
}
