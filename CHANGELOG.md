# Changelog

## [0.3.0](https://github.com/mrk21/firebrew/tree/v0.3.0) - 2014-09-30

* Future [#36](https://github.com/mrk21/firebrew/issues/36): Implement the `os` gem
* Future [#18](https://github.com/mrk21/firebrew/issues/18): Make it possible to display a download progress of the extension

## [0.2.0](https://github.com/mrk21/firebrew/tree/v0.2.0) - 2014-08-31

* Future [#35](https://github.com/mrk21/firebrew/issues/35): Add the subcommand help
* Future [#34](https://github.com/mrk21/firebrew/issues/34): Make the help message in detail
* Future [#33](https://github.com/mrk21/firebrew/issues/33): Change to 0 a return value of the help command and version command
* Bugfix [#32](https://github.com/mrk21/firebrew/issues/32): The `OptionParser` exceptions has not been handled enough
* Bugfix [#31](https://github.com/mrk21/firebrew/issues/31): Has not been throw the `SystemCall` exception when executed the command which is not existed
* Future [#30](https://github.com/mrk21/firebrew/issues/30): Add the detailed error messages
* Future [#29](https://github.com/mrk21/firebrew/issues/29): Change the command return value
* Future [#28](https://github.com/mrk21/firebrew/issues/28): Stop depending on `ActiveSupport`
* Future [#27](https://github.com/mrk21/firebrew/issues/27): Stop depending on `ActiveResource`
* Future [#26](https://github.com/mrk21/firebrew/issues/26): Stop depending on `ActiveModel`
* Future [#25](https://github.com/mrk21/firebrew/issues/25): Add the command of getting the profile information
* Future [#16](https://github.com/mrk21/firebrew/issues/16): The handling of when the network errors of the 404 Not Found HTTP error, etc occurs on the Amo::Search

## [0.1.3](https://github.com/mrk21/firebrew/tree/v0.1.3) - 2014-08-19

* Bugfix [#24](https://github.com/mrk21/firebrew/issues/24): When the `em:unpack` value of the install manifests was true, is unable to normally installing

## [0.1.2](https://github.com/mrk21/firebrew/tree/v0.1.2) - 2014-08-15

* Bugfix [#23](https://github.com/mrk21/firebrew/issues/23): If the `install` element of the extension which was got by the generic AMO API was equal or greater than two, then occurs errors
* Future [#22](https://github.com/mrk21/firebrew/issues/22): Designate the current platform to the `os` parameter when use the `Amo::Search`

## [0.1.1](https://github.com/mrk21/firebrew/tree/v0.1.1) - 2014-07-16

* Bugfix [#12](https://github.com/mrk21/firebrew/issues/12): The unit test failed on the Windows(#10): The 2 to 5 errors
* Bugfix [#11](https://github.com/mrk21/firebrew/issues/11): The unit test failed on the Windows(#10): The first error
* Bugfix [#9](https://github.com/mrk21/firebrew/issues/9): Is not able to install on the profile creation immediate aftermath
* Bugfix [#8](https://github.com/mrk21/firebrew/issues/8): The typo of the `Runner::default_options` for the Windows
