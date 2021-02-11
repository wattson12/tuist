import Foundation
import TSCBasic
import TuistCache
import TuistCore
import TuistGraph
import TuistLoader
import TuistSupport

final class CacheWarmService {
    /// Generator Model Loader, used for getting the user config
    private let generatorModelLoader: GeneratorModelLoader

    init(manifestLoader: ManifestLoader = ManifestLoader(),
         manifestLinter: ManifestLinter = ManifestLinter())
    {
        generatorModelLoader = GeneratorModelLoader(manifestLoader: manifestLoader,
                                                    manifestLinter: manifestLinter)
    }

    func run(path: String?, profile: String?, xcframeworks: Bool, targets: [String]) throws {
        let path = self.path(path)
        let config = try generatorModelLoader.loadConfig(at: path)
        let cache = Cache(storageProvider: CacheStorageProvider(config: config))
        let cacheControllerFactory = CacheControllerFactory(cache: cache)
        let contentHasher = CacheContentHasher()
        let cacheController: CacheControlling
        if xcframeworks {
            cacheController = cacheControllerFactory.makeForXCFramework(contentHasher: contentHasher)
        } else {
            cacheController = cacheControllerFactory.makeForSimulatorFramework(contentHasher: contentHasher)
        }

        let profile = try CacheProfileResolver().resolveCacheProfile(named: profile, from: config)
        try cacheController.cache(path: path, cacheProfile: profile, targetsToFilter: targets)
    }

    // MARK: - Helpers

    private func path(_ path: String?) -> AbsolutePath {
        if let path = path {
            return AbsolutePath(path, relativeTo: currentPath)
        } else {
            return currentPath
        }
    }

    private var currentPath: AbsolutePath {
        FileHandler.shared.currentPath
    }
}
