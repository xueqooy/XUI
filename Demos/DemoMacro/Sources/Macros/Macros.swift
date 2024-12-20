import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum CustomError: Error, CustomStringConvertible {
    case message(String)

    var description: String {
        switch self {
        case let .message(text):
            return text
        }
    }
}

public struct DemoEnumMacro: MemberMacro {
    public static func expansion(of _: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in _: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let elements = declaration.as(EnumDeclSyntax.self)?.memberBlock.members.compactMap({ $0.decl.as(EnumCaseDeclSyntax.self)?.elements.first }) else {
            throw CustomError.message("@DemoEnumMacro only works on enum that have associated value case")
        }

        let titleLiteral = """
        var title: String {
            var result = ""
            for (index, character) in rawValue.enumerated() {
                if index != 0 && character.isUppercase {
                    result += " "
                }
                result.append(character)
            }
            return result
        }
        """
        let titleDecl: VariableDeclSyntax = try .init(SyntaxNodeString(stringLiteral: titleLiteral))

        let casesLiteral: String = elements.reduce(into: "") { partialResult, element in
            let name = element.name.text
            partialResult +=
                """
                case .\(name):
                    viewController = \(name)DemoController()
                """
        }

        let viewControllerLiteral = """
        var viewController: DemoController {
            let viewController: DemoController
            switch self {
                \(casesLiteral)
            }
            viewController.title = title
            return viewController
        }
        """
        let viewControllerDecl: VariableDeclSyntax = try .init(SyntaxNodeString(stringLiteral: viewControllerLiteral))

        var result = [DeclSyntax(titleDecl), DeclSyntax(viewControllerDecl)]
        return result
    }
}

@main
struct DemoMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DemoEnumMacro.self,
    ]
}
