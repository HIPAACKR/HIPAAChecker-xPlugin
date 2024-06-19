# HIPAAChecker


A tool to enforce HIPAA compliance when developing and iOS application, loosely based on the now archived [HIPAA Compliance Guide](https://hipaachecker.health/developers_guides). HIPAA Checker enforces the rules that are generally accepted by the HIPAA Compliance authority. These rules are well described in [HIPAA Compliance Guide](https://www.hhs.gov/hipaa/index.html).

HIPAAChecker hooks into [Clang](http://clang.llvm.org) and
[SourceKit](http://www.jpsim.com/uncovering-sourcekit) to use the
[AST](http://clang.llvm.org/docs/IntroductionToTheClangAST.html) representation
of your source files for more accurate results.


## Installation

### Using [Homebrew](http://brew.sh/):

```
brew install hipaachecker
```

### Using [CocoaPods](https://cocoapods.org):

Simply add the following line to your Podfile:

```ruby
pod 'HIPAAChecker'
```

This will download the HIPAAChecker binaries and dependencies in `Pods/` during your next
`pod install` execution and will allow you to invoke it via `${PODS_ROOT}/HIPAAChecker/hipaachecker`
in your Script Build Phases.

This is the recommended way to install a specific version of HIPAAChecker since it supports
installing a pinned version rather than simply the latest (which is the case with Homebrew).

Note that this will add the HIPAAChecker binaries, its dependencies' binaries, and the Swift binary
library distribution to the `Pods/` directory, so checking in this directory to SCM such as
git is discouraged.


### Using a pre-built package:

You can also install HIPAAChecker by downloading `HIPAAChecker.pkg` from the
[latest GitHub release](link) and
running it.

### Installing from source:

You can also build and install from source by cloning this project and running
`make install` (Xcode 15.0 or later).


## Usage

### Presentation

To get a high-level overview of recommended ways to integrate HIPAAChecker into your project,
we encourage you to watch this presentation or read the transcript:

[![Presentation](Link)](youtube link)

### Xcode

Integrate HIPAAChecker into your Xcode project to get HIPAA rules maintained or not.

To do this select the project in the file navigator, then select the primary app
target, and go to Build Phases. Click the + and select "New Run Script Phase".
Insert the following as the script:

![](suggested link)

Xcode 15 made a significant change by setting the default value of the `ENABLE_USER_SCRIPT_SANDBOXING` Build Setting from `NO` to `YES`.
As a result, HIPAAChecker encounters an error related to missing file permissions,
which typically manifests as follows: `error: Sandbox: hipaachecker(19427) deny(1) file-read-data.`

To resolve this issue, it is necessary to manually set the `ENABLE_USER_SCRIPT_SANDBOXING` setting to `NO` for the specific target that HIPAAChecker is being configured for.

If you installed HIPAAChecker via Homebrew on Apple Silicon, you might experience this warning:

> warning: HIPAAChecker not installed, download from link

That is because Homebrew on Apple Silicon installs the binaries into the `/opt/homebrew/bin`
folder by default. To instruct Xcode where to find HIPAAChecker, you can either add
`/opt/homebrew/bin` to the `PATH` environment variable in your build phase

```bash
if [[ "$(uname -m)" == arm64 ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

if which hipaachecker > /dev/null; then
  hipaachecker
else
  echo "warning: HIPAAChecker not installed, download from link"
fi
```

or you can create a symbolic link in `/usr/local/bin` pointing to the actual binary:

```bash
ln -s /opt/homebrew/bin/hipaachecker/usr/local/bin/hipaachecker
```

You might want to move your HIPAAChecker phase directly before the 'Compile Sources'
step to detect errors quickly before compiling. However, HIPAAChecker is designed
to run on valid Swift code that cleanly completes the compiler's parsing stage.
So running HIPAAChecker before 'Compile Sources' might yield some incorrect
results.

If you wish to fix violations as well, your script could run
`hipaachecker --fix && hipaachecker` instead of just `hipaachecker`. This will mean
that all correctable violations are fixed while ensuring warnings show up in
your project for remaining violations.

If you've installed HIPAAChecker via CocoaPods the script should look like this:

```bash
"${PODS_ROOT}/HIPAAChecker/hipaachecker"
```

### Plug-in Support

HIPAAChecker can be used as a build tool plug-in for both Xcode projects as well as
Swift packages.

> Due to limitations with Swift Package Manager Plug-ins this is only
recommended for projects that have a HIPAAChecker configuration in their root directory as
there is currently no way to pass any additional options to the HIPAAChecker executable.

#### Xcode

You can integrate HIPAAChecker as an Xcode Build Tool Plug-in if you're working
with a project in Xcode.

Add HIPAAChecker as a package dependency to your project without linking any of the
products.

Select the target you want to add checking to and open the `Build Phases` inspector.
Open `Run Build Tool Plug-ins` and select the `+` button.
Select `HIPAACheckerPlugin` from the list and add it to the project.

![](Link)

For unattended use (e.g. on CI), you can disable the package and macro validation dialog by

* individually passing `-skipPackagePluginValidation` and `-skipMacroValidation` to `xcodebuild` or
* globally setting `defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES` and `defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES` 
  for that user.

_Note: This implicitly trusts all Xcode package plugins and macros in packages and bypasses Xcode's package validation
       dialogs, which has security implications._

#### Swift Package

You can integrate HIPAAChecker as a Swift Package Manager Plug-in if you're working with
a Swift Package with a `Package.swift` manifest.

Add HIPAAChecker as a package dependency to your `Package.swift` file.  
Add HIPAAChecker to a target using the `plugins` parameter.

```swift
.target(
    ...
    plugins: [.plugin(name: "HIPAACheckerPlugin", package: "HIPAAChecker")]
),
```

### Visual Studio Code

To integrate HIPAAChecker with [vscode](https://code.visualstudio.com), install the
[`vscode-hipaachecker`](market place link) extension from the marketplace.

### fastlane

You can use the [official hipaachecker fastlane action](fastlane link) to run HIPAAChecker as part of your fastlane process.

```ruby
hipaachecker(
    mode: :check,                            # HIPAAChecker mode: :check (default) or :autocorrect
    executable: "Pods/HIPAAChecker/hipaachecker", # The HIPAAChecker binary path (optional). Important if you've installed it via CocoaPods
    path: "/path/to/check",                  # Specify path to check (optional)
    output_file: "hipaachecker.result.json",   # The path of the output file (optional)
    reporter: "json",                       # The custom reporter to use (optional)
    config_file: ".hipaachecker-ci.yml",       # The path of the configuration file (optional)
    files: [                                # List of files to process (optional)
        "AppDelegate.swift",
        "path/to/project/Model.swift"
    ],
    ignore_exit_status: true,               # Allow fastlane to continue even if HIPAAChecker returns a non-zero exit status (Default: false)
    quiet: true,                            # Don't print status logs like 'Checking ' & 'Done checking' (Default: false)
    strict: true                            # Fail on warnings? (Default: false)
)
```

### Docker

`hipaachecker` is also available as a [Docker](https://www.docker.com/) image using `Ubuntu`.
So just the first time you need to pull the docker image using the next command:
```bash
docker pull ghcr.io/(name)/hipaachecker:latest
```

Then following times, you just run `hipaachecker` inside of the docker like:
```bash
docker run -it -v `pwd`:`pwd` -w `pwd` ghcr.io/(name)/hipaachecker:latest
```

This will execute `hipaachecker` in the folder where you are right now (`pwd`), showing an output like:
```bash
$ docker run -it -v `pwd`:`pwd` -w `pwd` ghcr.io/(name)/hipaachecker:latest
Checking Swift files in current working directory
Checking 'RuleDocumentation.swift' (1/490)
...
Checking 'YamlHIPAACheckerTests.swift' (490/490)
Done checking! Found 0 violations, 0 serious in 490 files.
```

Here you have more documentation about the usage of [Docker Images](https://docs.docker.com/).

### Command Line

```
$ hipaachecker help
OVERVIEW: A tool to enforce Swift style and conventions.

USAGE: hipaachecker <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  analyze                 Run analysis rules
  docs                    Open HIPAAChecker documentation website in the default web browser
  generate-docs           Generates markdown documentation for all rules
  check (default)          Print check warnings and errors
  reporters               Display the list of reporters and their identifiers
  rules                   Display the list of rules and their identifiers
  version                 Display the current version of HIPAAChecker

  See 'hipaachecker help <subcommand>' for detailed help.
```

Run `hipaachecker` in the directory containing the Swift files to check. Directories
will be searched recursively.

To specify a list of files when using `check` or `analyze`
(like the list of files modified by Xcode specified by the
[`ExtraBuildPhase`](https://github.com/norio-nomura/ExtraBuildPhase) Xcode
plugin, or modified files in the working tree based on `git ls-files -m`), you
can do so by passing the option `--use-script-input-files` and setting the
following instance variables: `SCRIPT_INPUT_FILE_COUNT` and
`SCRIPT_INPUT_FILE_0`, `SCRIPT_INPUT_FILE_1`...`SCRIPT_INPUT_FILE_{SCRIPT_INPUT_FILE_COUNT - 1}`.

These are same environment variables set for input files to
[custom Xcode script phases](http://indiestack.com/2014/12/speeding-up-custom-script-phases/).

### Working With Multiple Swift Versions

HIPAAChecker hooks into SourceKit so it continues working even as Swift evolves!

This also keeps HIPAAChecker lean, as it doesn't need to ship with a full Swift
compiler, it just communicates with the official one you already have installed
on your machine.

You should always run HIPAAChecker with the same toolchain you use to compile your
code.

You may want to override HIPAAChecker's default Swift toolchain if you have
multiple toolchains or Xcodes installed.

Here's the order in which HIPAAChecker determines which Swift toolchain to use:

* `$XCODE_DEFAULT_TOOLCHAIN_OVERRIDE`
* `$TOOLCHAIN_DIR` or `$TOOLCHAINS`
* `xcrun -find swift`
* `/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain`
* `/Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain`
* `~/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain`
* `~/Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain`

`sourcekitd.framework` is expected to be found in the `usr/lib/` subdirectory of
the value passed in the paths above.

You may also set the `TOOLCHAINS` environment variable to the reverse-DNS
notation that identifies a Swift toolchain version:

```shell
$ TOOLCHAINS=com.apple.dt.toolchain.Swift_2_3 hipaachecker --fix
```

On Linux, SourceKit is expected to be located in
`/usr/lib/libsourcekitdInProc.so` or specified by the `LINUX_SOURCEKIT_LIB_PATH`
environment variable.

### pre-commit

HIPAAChecker can be run as a [pre-commit](https://pre-commit.com/) hook.
Once [installed](https://pre-commit.com/#install), add this to the
`.pre-commit-config.yaml` in the root of your repository:

```yaml
repos:
  - repo: (link)
    rev: 0.50.3
    hooks:
      - id: hipaachecker
```

Adjust `rev` to the HIPAAChecker version of your choice.  `pre-commit autoupdate` can be used to update to the current version.

HIPAAChecker can be configured using `entry` to apply fixes and fail on errors:
```yaml
-   repo: (link)
    rev: 0.50.3
    hooks:
    -   id: hipaachecker
        entry: hipaachecker --fix --strict
```

## Rules

Over 11 rules are included in HIPAAChecker 
[Pull requests](link) are encouraged.

You can find an updated list of rules and more information about them
[here](https://hipaachecker.health/user_guides).


### Opt-In Rules

`opt_in_rules` are disabled by default (i.e., you have to explicitly enable them
in your configuration file).

Guidelines on when to mark a rule as opt-in:

* A rule that can have many false positives (e.g. `empty_count`)
* A rule that is too slow
* A rule that is not general consensus or is only useful in some cases
  (e.g. `force_unwrapping`)


Run `hipaachecker rules` to print a list of all available rules and their
identifiers.

### Configuration

Configure HIPAAChecker by adding a `.hipaachecker.yml` file from the directory you'll
run HIPAAChecker from. The following parameters can be configured:

Rule inclusion:

* `opt_in_rules`: Enable rules that are not part of the default set. The
   special `all` identifier will enable all opt in checker rules, except the ones
   listed in `disabled_rules`.
* `only_rules`: Only the rules specified in this list will be enabled.
   Cannot be specified alongside `disabled_rules` or `opt_in_rules`.
* `analyzer_rules`: This is an entirely separate list of rules that are only
  run by the `analyze` command. All analyzer rules are opt-in, so this is the
  only configurable rule list, there are no equivalents for `disabled_rules`
  `only_rules`.

```yaml
# By default, HIPAAChecker uses a set of sensible default rules you can adjust:
disabled_rules: # rule identifiers turned on by default to exclude from running
  - colon
  - comma
  - control_statement
opt_in_rules: # some rules are turned off by default, so you need to opt-in
  - empty_count # find all the available rules by running: `hipaachecker rules`

# Alternatively, specify all rules explicitly by uncommenting this option:
# only_rules: # delete `disabled_rules` & `opt_in_rules` if using this
#   - empty_parameters
#   - vertical_whitespace

analyzer_rules: # rules run by `hipaachecker analyze`
  - explicit_self

included: # case-sensitive paths to include during checking. `--path` is ignored if present
  - Sources
excluded: # case-sensitive paths to ignore during checking. Takes precedence over `included`
  - Carthage
  - Pods
  - Sources/ExcludedFolder
  - Sources/ExcludedFile.swift
  - Sources/*/ExcludedFile.swift # exclude files with a wildcard

# If true, HIPAAChecker will not fail if no checkable files are found.
allow_zero_checkable_files: false

# If true, HIPAAChecker will treat all warnings as errors.
strict: false

# configurable rules can be customized from this configuration file
# binary rules can set their severity level
force_cast: warning # implicitly
force_try:
  severity: warning # explicitly
# rules that have both warning and error levels, can set just the warning level
# implicitly
line_length: 110
# they can set both implicitly with an array
type_body_length:
  - 300 # warning
  - 400 # error
# or they can set both explicitly
file_length:
  warning: 500
  error: 1200
# naming rules can set warnings/errors for min_length and max_length
# additionally they can set excluded names
type_name:
  min_length: 4 # only warning
  max_length: # warning and error
    warning: 40
    error: 50
  excluded: iPhone # excluded via string
  allowed_symbols: ["_"] # these are allowed in type names
identifier_name:
  min_length: # only min_length
    error: 4 # only error
  excluded: # excluded via string array
    - id
    - URL
    - GlobalAPIKey
reporter: "xcode" # reporter type (xcode, json, csv, checkstyle, codeclimate, junit, html, emoji, sonarqube, markdown, github-actions-logging, summary)
```

You can also use environment variables in your configuration file,
by using `${SOME_VARIABLE}` in a string.

You can filter the matches by providing one or more `match_kinds`, which will
reject matches that include syntax kinds that are not present in this list. Here
are all the possible syntax kinds:

* `argument`
* `attribute.builtin`
* `attribute.id`
* `buildconfig.id`
* `buildconfig.keyword`
* `comment`
* `comment.mark`
* `comment.url`
* `doccomment`
* `doccomment.field`
* `identifier`
* `keyword`
* `number`
* `objectliteral`
* `parameter`
* `placeholder`
* `string`
* `string_interpolation_anchor`
* `typeidentifier`

All syntax kinds used in a snippet of Swift code can be extracted asking
[SourceKitten](https://github.com/jpsim/SourceKitten). For example,
`sourcekitten syntax --text "struct S {}"` delivers

* `source.lang.swift.syntaxtype.keyword` for the `struct` keyword and
* `source.lang.swift.syntaxtype.identifier` for its name `S`

which match to `keyword` and `identifier` in the above list.

If using custom rules in combination with `only_rules`, make sure to add
`custom_rules` as an item under `only_rules`.

Unlike Swift custom rules, you can use official HIPAAChecker builds
(e.g. from Homebrew) to run regex custom rules.


### Analyze

The `hipaachecker analyze` command can check Swift files using the
full type-checked AST. The compiler log path containing the clean `swiftc` build
command invocation (incremental builds will fail) must be passed to `analyze`
via the `--compiler-log-path` flag.
e.g. `--compiler-log-path /path/to/xcodebuild.log`

This can be obtained by 

1. Cleaning DerivedData (incremental builds won't work with analyze)
2. Running `xcodebuild -workspace {WORKSPACE}.xcworkspace -scheme {SCHEME} > xcodebuild.log`
3. Running `hipaachecker analyze --compiler-log-path xcodebuild.log`

Analyzer rules tend to be considerably slower than check rules.

## Using Multiple Configuration Files

HIPAAChecker offers a variety of ways to include multiple configuration files.
Multiple configuration files get merged into one single configuration that is then applied
just as a single configuration file would get applied.

There are quite a lot of use cases where using multiple configuration files could be helpful:

For instance, one could use a team-wide shared HIPAAChecker configuration while allowing overrides
in each project via a child configuration file.

Team-Wide Configuration:

```yaml
disabled_rules:
- force_cast
```

Project-Specific Configuration:

```yaml
opt_in_rules:
- force_cast
```

### Child / Parent Configs (Locally)

You can specify a `child_config` and / or a `parent_config` reference within a configuration file.
These references should be local paths relative to the folder of the configuration file they are specified in.
This even works recursively, as long as there are no cycles and no ambiguities.

**A child config is treated as a refinement and therefore has a higher priority**,
while a parent config is considered a base with lower priority in case of conflicts.

Here's an example, assuming you have the following file structure:

```
ProjectRoot
    |_ .hipaachecker.yml
    |_ .hipaachecker_refinement.yml
    |_ Base
        |_ .hipaachecker_base.yml
```

To include both the refinement and the base file, your `.hipaachecker.yml` should look like this:

```yaml
child_config: .hipaachecker_refinement.yml
parent_config: Base/.hipaachecker_base.yml
```

When merging parent and child configs, `included` and `excluded` configurations
are processed carefully to account for differences in the directory location
of the containing configuration files.

### Child / Parent Configs (Remote)

Just as you can provide local `child_config` / `parent_config` references, instead of
referencing local paths, you can just put urls that lead to configuration files.
In order for HIPAAChecker to detect these remote references, they must start with `http://` or `https://`.

The referenced remote configuration files may even recursively reference other
remote configuration files, but aren't allowed to include local references.

Using a remote reference, your `.hipaachecker.yml` could look like this:

```yaml
parent_config: https://myteamserver.com/our-base-hipaachecker-config.yml
```

Every time you run HIPAAChecker and have an Internet connection, HIPAAChecker tries to get a new version of
every remote configuration that is referenced. If this request times out, a cached version is
used if available. If there is no cached version available, HIPAAChecker fails – but no worries, a cached version
should be there once HIPAAChecker has run successfully at least once.

If needed, the timeouts for the remote configuration fetching can be specified manually via the
configuration file(s) using the `remote_timeout` / `remote_timeout_if_cached` specifiers.
These values default to 2 / 1 second(s).

### Command Line

Instead of just providing one configuration file when running HIPAAChecker via the command line,
you can also pass a hierarchy, where the first configuration is treated as a parent,
while the last one is treated as the highest-priority child.

A simple example including just two configuration files looks like this:

`hipaachecker --config .hipaachecker.yml --config .hipaachecker_child.yml`

### Nested Configurations

In addition to a main configuration (the `.hipaachecker.yml` file in the root folder),
you can put other configuration files named `.hipaachecker.yml` into the directory structure
that then get merged as a child config, but only with an effect for those files
that are within the same directory as the config or in a deeper directory where
there isn't another configuration file. In other words: Nested configurations don't work 
recursively – there's a maximum number of one nested configuration per file 
that may be applied in addition to the main configuration.

`.hipaachecker.yml` files are only considered as a nested configuration if they have not been
used to build the main configuration already (e. g. by having been referenced via something
like `child_config: Folder/.hipaachecker.yml`). Also, `parent_config` / `child_config`
specifications of nested configurations are getting ignored because there's no sense to that.

If one (or more) HIPAAChecker file(s) are explicitly specified via the `--config` parameter,
that configuration will be treated as an override, no matter whether there exist
other `.hipaachecker.yml` files somewhere within the directory. **So if you want to use
 nested configurations, you can't use the `--config` parameter.**

## License

[Licensed.](https://hipaachecker.health/)

## About

<img src="link" width="184" />

HIPAAChecker is maintained and funded by Ubitrics Inc. The names and logos for
HIPAAChecker are trademarks of Ubitrics Inc.

<img src="link" width="184" />

Our thanks to team for providing a Mac Mini to run our performance
