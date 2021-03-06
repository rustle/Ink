/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Heading: ReadableFragment {
    var modifierTarget: Modifier.Target { .headings }
    var level: Int

    private var text: FormattedText

    static func read(using reader: inout Reader,
                     references: inout NamedReferenceCollection) throws -> Heading {
        let level = reader.readCount(of: "#")
        try require(level > 0 && level < 7)
        try reader.readWhitespaces()
        let text = FormattedText.read(using: &reader,
                                      references: &references,
                                      terminators: ["\n"])

        return Heading(level: level,
                       text: text)
    }

    func html(usingReferences references: NamedReferenceCollection,
              modifiers: ModifierCollection) -> String {
        let body = stripTrailingMarkers(
            from: text.html(usingReferences: references, modifiers: modifiers)
        )

        let tagName = "h\(level)"
        return "<\(tagName)>\(body)</\(tagName)>"
    }

    func plainText() -> String {
        stripTrailingMarkers(from: text.plainText())
    }
}

private extension Heading {
    func stripTrailingMarkers(from text: String) -> String {
        guard !text.isEmpty else { return text }

        let lastCharacterIndex = text.index(before: text.endIndex)
        var trimIndex = lastCharacterIndex

        while text[trimIndex] == "#", trimIndex != text.startIndex {
            trimIndex = text.index(before: trimIndex)
        }

        if trimIndex != lastCharacterIndex {
            return String(text[..<trimIndex])
        }

        return text
    }
}
