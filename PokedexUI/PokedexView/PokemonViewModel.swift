import SwiftUI

/// Protocol for Pokémon view models providing display-ready Pokémon data.
protocol PokemonViewModelProtocol {
    /// The Pokémon front sprite image.
    var frontImage: UIImage? { get }
    /// The Pokémon back sprite image.
    var backImage: UIImage? { get }
    /// The dominant color extracted from the image.
    var color: Color? { get }
    /// Indicates if the color is light for UI adjustments.
    var isLight: Bool { get }
    /// Types associated with the Pokémon.
    var types: String { get }
    /// Abilities associated with the Pokémon.
    var abilities: String { get }
    /// Display-ready Pokémon name.
    var name: String { get }
    /// Statistics for the Pokémon.
    var stats: [Stat] { get }
    /// Main moves for the Pokémon (first 20, comma-separated).
    var moves: String { get }
    /// Pokémon height, formatted for display.
    var height: String { get }
    /// Pokémon weight, formatted for display.
    var weight: String { get }
    /// Unique Pokémon identifier.
    var id: Int { get }
    /// The battle cry of the pokemon.
    var latestCry: String? { get }

    /// Loads the sprite image asynchronously and updates color.
    func loadSprite() async
    /// Play the battle cry of the pokemon.
    func playSound(_ battleCry: String) async
}

// MARK: -
/// ViewModel providing formatted and display-ready data for a single Pokémon.
@Observable
final class PokemonViewModel {
    // MARK: Private properties
    private let audioStreamer: AudioPlayer
    private let imageLoader: ImageLoader
    private let pokemon: Pokemon

    // MARK: - Public properties
    var frontImage: UIImage?
    var backImage: UIImage?
    var color: Color?

    /// Initializes the ViewModel with Pokémon details and an optional image loader.
    /// - Parameters:
    ///   - pokemon: The detailed Pokémon model.
    ///   - imageLoader: The loader for sprite images.
    ///   - audioStreamer: The audio player to play the pokemon battle cry.
    init(
        pokemon: Pokemon,
        imageLoader: ImageLoader = .init(),
        audioStreamer: AudioPlayer = .init()
    ) {
        self.audioStreamer = audioStreamer
        self.imageLoader = imageLoader
        self.pokemon = pokemon
    }
}

// MARK: - PokemonViewModelProtocol
/// Implementation of protocol requirements for PokemonViewModel.
extension PokemonViewModel: PokemonViewModelProtocol {
    var id: Int { pokemon.id }
    var name: String { pokemon.name.capitalized }
    var height: String { "\(Double(pokemon.height) / 10.0) m" }
    var weight: String { "\(Double(pokemon.weight) / 10.0) kg" }
    var isLight: Bool { color?.isLight ?? false }
    var types: String { pokemon.types.map { $0.type.name.capitalized }.joined(separator: ", ") }
    var abilities: String { pokemon.abilities.map { $0.ability.name.capitalized }.joined(separator: ",\n\n") }
    var stats: [Stat] { pokemon.stats }
    var latestCry: String? { pokemon.cries.latest }

    var moves: String {
        let count = pokemon.moves.count
        let end = min(count, 20)
        return pokemon.moves[0 ..< end].map { $0.move.name.capitalized }.joined(separator: ", ")
    }

    @MainActor
    func loadSprite() async {
        frontImage = await imageLoader.loadImage(from: pokemon.sprite.front)
        backImage = await imageLoader.loadImage(from: pokemon.sprite.back)
        color = Color(uiColor: frontImage?.dominantColor ?? .darkGray)
    }

    @MainActor
    func playSound(_ battleCry: String) async {
        await audioStreamer.play(from: battleCry)
    }
}

// MARK: - Equatable
extension PokemonViewModel: Equatable {
    static func == (lhs: PokemonViewModel, rhs: PokemonViewModel) -> Bool {
        lhs.id == rhs.id
    }
}
