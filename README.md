# Firebrew

Firefox add-ons manager for CUI.

## Installation

Add this line to your application's Gemfile:

    gem 'firebrew'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install firebrew


_NOTE: This program execution requires the OpenSSL._

## Usage

The structure of the command line is shown below:

```bash
$ firebrew [--help] [--version]
           [--base-dir=<path>] [--profile=<name>] [--firefox=<path>]
           <command> [<args>]
```

### commands

#### install

Install the extension which is designated by the `extension-name` argument:

```bash
$ firebrew install <extension-name>
```

#### uninstall

Uninstall the extension which is designated by the `extension-name` argument:

```bash
$ firebrew uninstall <extension-name>
```

#### info

Show detail information of the extension which is designated by the `extension-name` argument:

```bash
$ firebrew info <extension-name>
```

#### search

Enumerate the remote extensions whose name is matched the `term` argument:

```bash
$ firebrew search <term>
```

#### list

Enumerate the installed extensions:

```bash
$ firebrew list
```

### options

#### --base-dir

The Firefox profiles.ini directory:

```bash
-d <path>, --base-dir=<path>
```

The default value is listed below:

| platform | value |
| -------- | ----- |
| Mac OS X | `~/Library/Application Support/Firefox` | 
| Linux    | `~/.mozilla/firefox` |
| Windows  | `%APPDATA%\Mozilla\Firefox` |

It's able to overridden by the `FIREBREW_FIREFOX_PROFILE_BASE_DIR` environment variable.

#### --profile-name

The Firefox profile name:

```bash
-p <name>, --profile=<name>
```

The default value is `default`, and it's able to overridden by the `FIREBREW_FIREFOX_PROFILE` environment variable.

#### --firefox

The Firefox command path:

```bash
-f <path>, --firefox=<path>
```

The default value is listed below:

| platform | value |
| -------- | ----- |
| Mac OS X | `/Applications/Firefox.app/Contents/MacOS/firefox-bin` |
| Linux    | `/usr/bin/firefox` |
| Windows  | `%PROGRAMFILES%\Mozilla Firefox\firefox.exe` or `%PROGRAMFILES(X86)%\Mozilla Firefox\firefox.exe` |

It's able to overridden by the `FIREBREW_FIREFOX` environment variable.


## Contributing

1. Fork it ( http://github.com/mrk21/firebrew/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

