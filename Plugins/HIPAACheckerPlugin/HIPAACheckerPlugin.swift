import Foundation
import PackagePlugin

@main
struct HIPAACheckerPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let sourceTarget = target as? SourceModuleTarget else {
            return []
        }
        return createBuildCommands(
            inputFiles: sourceTarget.sourceFiles(withSuffix: "HIPAA").map(\.path),
            packageDirectory: context.package.directory,
            workingDirectory: context.pluginWorkDirectory,
            tool: try context.tool(named: "HIPAAChecker")
        )
    }

    private func createBuildCommands(
        inputFiles: [Path],
        packageDirectory: Path,
        workingDirectory: Path,
        tool: PluginContext.Tool
    ) -> [Command] {
        if inputFiles.isEmpty {
            // Don't check anything if there are no Swift source files in this target
            return []
        }

        var arguments = [
            "check",
            "--quiet",
            // We always pass all of the Swift source files in the target to the tool,
            // so we need to ensure that any exclusion rules in the configuration are
            // respected.
            "--force-exclude",
            "--cache-path", "\(workingDirectory)"
        ]

        // Manually look for configuration files, to avoid issues when the plugin does not execute our tool from the
        // package source directory.
        if let configuration = packageDirectory.firstConfigurationFileInParentDirectories() {
            arguments.append(contentsOf: ["--config", "\(configuration.string)"])
        }
        arguments += inputFiles.map(\.string)

        // We are not producing output files and this is needed only to not include cache files into bundle
        let outputFilesDirectory = workingDirectory.appending("Output")

        return [
            .prebuildCommand(
                displayName: "HIPAAChecker",
                executable: tool.path,
                arguments: arguments,
                outputFilesDirectory: outputFilesDirectory
            )
        ]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension HIPAACheckerPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        let inputFilePaths = target.inputFiles
            .filter { $0.type == .source && $0.path.extension == "HIPAA" }
            .map(\.path)
        return createBuildCommands(
            inputFiles: inputFilePaths,
            packageDirectory: context.xcodeProject.directory,
            workingDirectory: context.pluginWorkDirectory,
            tool: try context.tool(named: "HIPAAChecker")
        )
    }
}
#endif
