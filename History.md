# 1.2.0 / 22.01.21

* .travis.yml -> GithubActions
* Fix problem when ressource is nil

# 1.1.9 / 05.11.20
* Handle case where to_html.to_s returns a frozen string
  see https://github.com/zdavatz/oddb.org/issues/118

# 1.1.8 / 22.06.20

* Handle '+' in components correctly

# 1.1.7 / 16.06.20

* revert loading javascripts, as interactions do not work

# 1.1.6 / 12.06.20

* Fix 2 problems with frozen string and Ruby 2.7.1
** Added tests for to_html with strings: empty, with umlaut, with escaped chars

# 1.1.5 / 04.06.20

* Update to Ruby 2.7.1
* Inline *.css and *.js for faster loading.
** This works also when the css/js files are zipped
** But zipped css/js are unreadable via developert tools

# 1.1.4 / 19.04.2017

* Fix dynamic_html for MSIE browser
* Fix quoting for dojo.tooltip

# 1.1.3 / 15.08.2016

* Add session variable fallback assignment

# 1.1.2 / 10.08.2016

* Fix warnings by syntax or coding style
* Fix test errors
* Fix asset (doc) files permission
* Fix installation issues on ruby 2.0.0 and 2.1.9
* Add ruby 2.3.1 as ci target

# 1.1.1 / 07.07.2016

* Improve dojotoolkit.rb

# 1.1.0 / 06.07.2016

* Rename djConfig to dojoConfig
* Rename dojoType to data-dojo-type
* Remove duplicated dojoConfig (use only data-dojo-config)
* Add package support for onload script

# 1.0.9 / 05.07.2016

* Made tooltip work with dojo 1.11
* Only tested with dojo 1.11. Works probably with dojo >= 1.8.

# 1.0.8 / 10.05.2015

* Removed C-interface
* Removed obsolete tests for RUBY_VERSION < 1.9
* Ported to Ruby 2.3.0. Updated minitest. Use newer version of sbsm.
* Ruby 1.9.3 is no longer supported

# 1.0.7 / 03.12.2013

* Remove LEGACY_INTERFACE. No. LEGACY_INTERFACE was readded before release 1.0.7
* Make travis work just fine.

# 1.0.6 / 06.04.2012

*  Updated onload problem against dojo 1.7
*  Removed old version support

# 1.0.5 / 23.02.2012

* trying to get rid of htmlgrid.so

# 1.0.4 / 23.12.2011

* Added force_encoding('utf-8') to the return value of Grid#to_html method

# 1.0.3 / 23.12.2011

* patch grid.c for Ruby 1.9.3

# 1.0.2 / 23.12.2011

* Fix FachinfoDocument encoding error

# 1.0.1 / 09.12.2011

* Updated component.rb to be compatible for both Ruby 1.8 and 1.9
* Fixed require grid.o for gem install case

# 1.0.0 / 16.12.2010

* htmlgrid is now Ruby 1.9 ready.

  * Birthday!

