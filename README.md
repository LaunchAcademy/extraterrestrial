# ET

A command-line utility for downloading and submitting code challenges.

When running locally, use the following command to avoid using the installed gem version:

```no-highlight
$ bundle exec bin/et help

NAME
    et -

SYNOPSIS
    et [global options] command [command options] [arguments...]

VERSION
    0.5.1

GLOBAL OPTIONS
    --help    - Show this message
    --version - Display the program version

COMMANDS
    get    - Download lesson to your working area.
    help   - Shows a list of commands or help for one command
    init   - Initialize current directory as a work area.
    list   - List available lessons.
    submit - Submit the lesson in this directory.
    test   - Run an exercise test suite.
```

### Releasing New Versions

Bundler provided `gem_tasks` have been incorporated into this libraries
`Rakefile`. Thankfully these tasks make releasing new gem versions a snap!

To release a new version of this gem:

1. Bump the version according to [semantic versioning](http://semver.org/)
2. Perform a git commit
3. Run `rake release` from the project root

Bundler's provided rake task will appropriately push a tag to GitHub and the gem
itself to [rubygems.org](https://rubygems.org)

_Note:_ in order to release the gem you must be an authorized owner of it on
[rubygems.org](https://rubygems.org)
