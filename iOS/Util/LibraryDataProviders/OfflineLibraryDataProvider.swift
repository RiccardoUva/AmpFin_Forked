//
//  OfflineLibraryDataProvider.swift
//  Music
//
//  Created by Rasmus Krämer on 09.09.23.
//

import Foundation
import AFBaseKit
import AFOfflineKit

public struct OfflineLibraryDataProvider: LibraryDataProvider {
    public var supportsArtistLookup: Bool = false
    public var supportsFavoritesLookup: Bool = false
    public var supportsAdvancedFilters: Bool = false
    
    public func getAllTracks(sortOrder: JellyfinClient.ItemSortOrder, ascending: Bool) async throws -> [Track] {
        let tracks = try await OfflineManager.shared.getTracks().sorted {
            switch sortOrder {
            case .name:
                return $0.name < $1.name
            case .album:
                return $0.album.name ?? "?" < $1.album.name ?? "?"
            case .albumArtist:
                return $0.album.artists.first?.name ?? "?" < $1.album.artists.first?.name ?? "?"
            case .artist:
                return $0.artists.first?.name ?? "?" < $1.artists.first?.name ?? "?"
            case .added, .released:
                return $0.releaseDate ?? Date(timeIntervalSince1970: 0) < $1.releaseDate ?? Date(timeIntervalSince1970: 0)
            case .plays, .runtime:
                return false
            }
        }
        
        return ascending ? tracks : tracks.reversed()
    }
    public func getFavoriteTracks(sortOrder: JellyfinClient.ItemSortOrder, ascending: Bool) async throws -> [Track] {
        return []
    }
    
    public func getRecentAlbums() async throws -> [Album] {
        try await OfflineManager.shared.getRecentAlbums()
    }
    public func getRecommendedAlbums() async throws -> [Album] {
        return try await getRecentAlbums()
    }
    
    public func getAlbumTracks(id: String) async throws -> [Track] {
        return try await OfflineManager.shared.getTracks(albumId: id)
    }
    public func getAlbumById(_ albumId: String) async throws -> Album? {
        await OfflineManager.shared.getAlbum(albumId: albumId)
    }
    public func getAlbums(limit: Int, sortOrder: JellyfinClient.ItemSortOrder, ascending: Bool) async throws -> [Album] {
        let albums = try await OfflineManager.shared.getAlbums().sorted {
            switch sortOrder {
            case .name, .album:
                return $0.name < $1.name
            case .albumArtist, .artist:
                return $0.artists.first?.name ?? "?" < $1.artists.first?.name ?? "?"
            case .added, .released:
                return $0.releaseDate ?? Date(timeIntervalSince1970: 0) < $1.releaseDate ?? Date(timeIntervalSince1970: 0)
            case .plays, .runtime:
                return false
            }
        }

        return ascending ? albums : albums.reversed()
    }
    
    public func getArtists(albumOnly: Bool) async throws -> [Artist] {
        return []
    }
    
    public func getArtistAlbums(id: String, sortOrder: JellyfinClient.ItemSortOrder, ascending: Bool) async throws -> [Album] {
        return []
    }
    
    public func getArtistById(_ artistId: String) async throws -> Artist? {
        return nil
    }
    
    public func searchTracks(query: String) async throws -> [Track] {
        try await OfflineManager.shared.getTracks(query: query)
    }
    
    public func searchAlbums(query: String) async throws -> [Album] {
        try await OfflineManager.shared.getAlbums(query: query)
    }
    
    public init() {
    }
}