
The files in this folder are the allowlists for the testsuite results that are passed as an argument for the `arc-gnu-toolchain/scripts/testsuite-filter` script.

Here is an example of how the JSON file format for gcc tool may be structured:
```json
{
    "common": [
      {
        "comment": "These are commons tests 01",
        "tests": [
            "FAIL: folder/test_01.S compilation"
            "XPASS: folder/test_02.S compilation"
            "FAIL: folder/test_03.S compilation"
        ]
      },
      {
        "comment": "These are commons tests 02",
        "tests": [
            "FAIL: folder/test_04.S compilation"
            "XPASS: folder/test_05.S compilation"
            "FAIL: folder/test_06.S compilation"
        ]
      }
    ],
    "glibc": [
      {
        "comment": "These are related to glibc",
        "tests": [
            "FAIL: folder/test_07.S compilation"
            "XPASS: folder/test_08.S compilation"
            "FAIL: folder/test_09.S compilation"
        ]
      }
    ],
    "newlib": [
      {
        "comment": "These are related to newlib",
        "tests": [
            "FAIL: folder/test_10.S compilation"
            "XPASS: folder/test_11.S compilation"
            "FAIL: folder/test_12.S compilation"
        ]
      }
    ]
}
```


In the JSON file, the first key is used to specify the `libc` used in the testsuite-filter execution (e.i. glibc, newlib). This key is essential for filtering the test results based on the specific library used.

The `common` category in the JSON file represents the common tests that are applicable to all C libraries.

```json
{
    "common": [
        ...
    ],
    "glibc": [
        ...
    ],
    "newlib": [
        ...
    ]
}
```


The `libc` (e.i. glibc, newlib) key in the JSON file consists of an array that allows multiple objects to be included, each with specific `comment` and related `tests`. 

<!-- Each test object contains two keys: `comment` and `tests`. -->
- The `comment` key contains a string that describes the purpose or context of the tests.
```json
    "comment": "These are commons tests 01",
```
- The `tests` key contains a list of strings that represent the individual test results.
```json
    "tests": [
        "FAIL: folder/test_01.S compilation",
        "XPASS: folder/test_02.S compilation",
        "FAIL: folder/test_03.S compilation"
    ]
```
