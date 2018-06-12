====================================
Health - A CI data analysis pipeline
====================================

Building and Deploy
===================

The Docker images used by Health can be built locally through make or using
skaffold_.

.. code:: shell

  # Build locally using make
  make

Skaffold also pushes the image to the specified registry and deployes the helm
chart to either minikube or a remote cluster.

.. code:: shell

  # Build locally and push to registry using skaffold
  export IMAGE_REG=registry.ng.bluemix.net/ci-pipeline
  export PR_NUMBER=<pull request number>
  skaffold run

Skaffold can be used in development mode, in which case it will monitor the
workspace of all Docker images for changes and automatically re-trigger a build
when something changes and re-deploy.

.. code:: shell

  # Using skaffold
  export IMAGE_REG=registry.ng.bluemix.net/ci-pipeline
  skaffold dev

Note: the skaffold configuration uses a skaffold feature which is not merged
yet: https://github.com/GoogleContainerTools/skaffold/pull/602.

.. _skaffold: https://github.com/GoogleContainerTools/skaffold

Using Health
============

To leverage this system we need to populate test results in the database.
Ideally this will be integrated into the post processing steps of your CI
system to automatically collect the data. This section will cover some examples
with different test runners and languages to show how you would do this. There
are 4 different techniques for doing this, which one you use depends greatly
on how you're running tests and the exact details of your environment.

Subunit Emitting Test Runner
----------------------------

The most straightforward mechanism to populate data into the database is if
you're running tests with a test runner that natively supports generating
subunit v2. Depending on the language used for testing there are some options.
If you have a subunit stream either as a file or stdout from your test runner
you can just pass that to the subunit2sql command directly to insert the
results into the database.

Python
''''''
On python you can use `stestr`_, `testrepository`_, or `subunit.run`_ for this.
These will work on any `unittest`_ compliant test suite. In fact `subunit.run`_
is just a drop-in replacement for *unittest.run*. So instead of running::

  $ python -m unittest.run test_suite

you just run::

  $ python -m subunit.run test_suite

which will emit the results as a subunit stream to stdout. You can just
pipe that to stdin of subunit2sql like::

  $ python -m subunit.run test_suite | subunit2sql ...

However, leveraging subunit.run (or unittest.run) is quite a limited test runner
so it's probably better to use a more feature-rich tool. `stestr`_ is the better
choice for this, while similar to testrepository, it's actively maintained and
provides a better feature-set. To best use stestr it requires a small
configuration file in repo to define how to perform test discovery. At the
minimum that's just::

  [DEFAULT]
  test_path=<PATH_TO_TEST_DIR>

With that set you can just call *stestr run* to run your test suite after that.
If you don't want to write a configuration file you can just specify the
test_path on the cli like::

    $ stestr --test-path <PATH_TO_TEST_DIR> run

stestr by default runs tests in parallel, so you might need the *--serial* flag
if your testing was developed with that in mind. To get subunit output from
the tests there are 2 methods. The first is to add the *--subunit* flag to the
run command. This will change the default output from something human readable
to subunit v2. Then you can just pipe this directly into subunit2sql like above
with subunit.run. Alternatively if you want to retain the human readable output
during the run you can call subunit last after the run to generate a subunit
stream for the run. For example::

    $ stestr run
    $ stestr last --subunit | subunit2sql ...

.. _stestr: http://stestr.readthedocs.io/en/latest/
.. _testrepository: http://testrepository.readthedocs.io/en/latest/
.. _subunit.run: https://github.com/testing-cabal/subunit#python
.. _unnitest: https://docs.python.org/2.7/library/unittest.html

Javascript
''''''''''
If you're using `karma`_ as your test runner for JS tests you can use the
`karma-subunit-reporter`_ plugin to enable subunit output. This is
straightforward and just involves installing the plugin with npm and adding
the following configuration in your karma.conf.js::

    module.exports = function(config) {
      config.set({
        // ...

        reporters: ['subunit'], // <---- This can contain any other reporters
                                //       just ensure subunit is in the list
        // ...
      });
    };

Then you can customize the subunit output settings by adding a
*subunitReporter* object to your config. For example::

    module.exports = function(config) {
      config.set({
        reporters: ['subunit'],

        // ...

        subunitReporter: {
          outputFile: 'karma.subunit',
          tags: [],      // tag strings to append to all tests
          slug: false,   // convert whitespace to '_'
          separator: '.' // separator for suite components + test name
        }
      });
    };

Which just explicitly sets the defaults. After you run karma it will now write
a subunit file to the path specified in the config (or the default karma.subunit).
You can just load that directly with the *subunit2sql* cli::

    $ subunit2sql karma.subunit

.. _karma: https://karma-runner.github.io/2.0/index.html
.. _karma-subunit-reporter: https://www.npmjs.com/package/karma-subunit-reporter

Converting results to subunit
-----------------------------

The second option for populating results in the database is to still leverage
the *subunit2sql* CLI is to convert a different results format into subunit.
This gives you more flexability in runner and language used for testing since
the conversion step can happen in any language. This section will cover some
common examples for doing this.

junitxml
''''''''

junitxml is another popular results format, mostly due to its native support in
jenkins. A lot of popular test runners, like `pytest`_ natively support writing
junitxml results. This makes converting from junitxml to subunit a popular
choice. This repo includes a small utility to convert junitxml (and xunitxml,
which is similar) to subunit v2 output. To run this you either pass the
junitxml in via stdin or pass the path to an junitxml file as the sole argument
to the script. For example::

    $ ./junitxml2subunit.py junitxml.xml

This can easily be tied to using a test runner like `pytest`_ to generate
junitxml and then simply follow-up by converting that to subunit. Then you
pass that subunit output directly into subunit2sql. For example::

    $ pytest PATH_TO_TEST_DIR --junitxml=results.xml
    $ ./junitxml2subunit.py results.xml | subunit2sql ...

.. _pytest: https://docs.pytest.org/en/latest/

Additionally you can use the Rust `junitxml2subunit`_ project for a faster
tool performing the same conversion.

.. _junitxml2subunit: https://crates.io/crates/junitxml2subunit


Writing your own conversion
'''''''''''''''''''''''''''

The final option is to write a converter from whatever test results format
you're using to subunit. This isn't as difficult as it seems. There are several
examples out there, mostly in python (since this is the primary langauge for
the upstream subunit library), for doing this. But, there are subunit v2
bindings available for multiple languages including `Javascript`_, `Python`_,
`Rust`_, and `Go`_. Then there are also subunit v1 (which can easily be
converted to v2 using the subunit-1to2 utility) bindings available for even
more languages including `C`_, `C++`_, `shell`_, and `Perl`_. If you're using
python you can refer to the [junitxml2subunit.py](junitxml2subunit.py) file
in this repo for an example. Another example performing the same conversion
(JUnit XML to subunit v2) can be found in rust with the
`junitxml2subunit project`_, if you'd like to implement a converter in rust.

.. _Javascript: https://github.com/testing-cabal/subunit-js/
.. _Python: https://pypi.org/project/python-subunit/
.. _Rust: https://github.com/mtreinish/subunit-rust
.. _Go: https://github.com/testing-cabal/subunit-go
.. _C: https://github.com/testing-cabal/subunit/tree/master/c
.. _C++: https://github.com/testing-cabal/subunit/tree/master/c%2B%2B
.. _shell: https://github.com/testing-cabal/subunit/tree/master/shell
.. _Perl: https://github.com/testing-cabal/subunit/tree/master/perl
.. _junitxml2subunit project: https://github.com/mtreinish/junitxml2subunit

Manually Generating Subunit
---------------------------

Another option for populating results is to manually generate your own subunit.
There are two tools that are useful for this. The *subunit-output* command,
packaged in the `python-subunit library`_ and the `generate-subunit`_ tool which
is packaged in the `os-testr`_ package. *subunit-output* provides low level
protocol access to write very custom subunit results. While *generate-subunit*
provides a simpler higher level interface. Either will work, but using
*generate-subunit* is probably easier. For example, you can use it to build a
results stream by concatenating the output several times::

    $ generate-subunit %(date +%s) 42 success test_a > output.subunit
    $ generate-subunit %(date +%s) 10 fail test_b >> output.subunit
    $ generate-subunit %(date +%s) 20 success test_c >> output.subunit

.. _python-subunit library: https://pypi.org/project/python-subunit/
.. _generate-subunit: https://docs.openstack.org/os-testr/latest/user/generate_subunit.html
.. _os-testr: https://pypi.org/project/os-testr/

Custom results processor
------------------------

The final option to directly populate the DB with results your testing. While
subunit is in the name of subunit2sql, this was an artifact of it's original
goal, not a design limitation. The actual data model and consumption side
are not specific to the subunit protocol and can be leveraged directly with
little effort. The SQL schema is not very complex for subunit2sql and directly
inserting new results is not difficult. The schema/data model is documented
here: https://docs.openstack.org/subunit2sql/latest/reference/data_model.html

When writing your own results processor you can either leverage the subunit2sql
`Python API`_ which provides a convenient methods to add results to the DB
directly. Or you can just directly connect to the DB and insert records manually
using whatever tools work best for your environment. It's worth noting that the
DB schema is not stable between releases and migrations may be run to change
how data is stored in the database. If you manually insert data into the
database you might have to update that when you upgrade the database. One
of the advantages the `Python API`_ is that it provides a consistent stable
interface between versions.

.. _Python API: https://docs.openstack.org/subunit2sql/latest/reference/api.html
.. _sqlalchemy: https://www.sqlalchemy.org/
