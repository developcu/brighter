public struct BoostSetting: Equatable {
    public let factor: Double
    public let maximumFactor: Double

    public var isSupported: Bool { maximumFactor > 1 }

    public init(requested: Double, headroom: Double) {
        let safeHeadroom = headroom.isFinite ? min(4, max(1, headroom)) : 1
        maximumFactor = safeHeadroom
        factor = requested.isFinite ? min(max(1, requested), safeHeadroom) : 1
    }
}
