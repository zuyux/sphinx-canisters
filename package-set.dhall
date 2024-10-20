let upstream = https://github.com/dfinity/vessel-package-set/releases/download/mo-0.13.2-20241018/package-set.dhall sha256:59874bbde8a634852696fbbaca49ad4a57ad56a17ea5464d263bdc1f446a720e
let Package =
    { name : Text, version : Text, repo : Text, dependencies : List Text }

let
  -- This is where you can add your own packages to the package-set
  additions =
    [] : List Package

let
  {- This is where you can override existing packages in the package-set

     For example, if you wanted to use version `v2.0.0` of the foo library:
     let overrides = [
         { name = "foo"
         , version = "v2.0.0"
         , repo = "https://github.com/bar/foo"
         , dependencies = [] : List Text
         }
     ]
  -}
  overrides =
    [] : List Package

in  upstream # additions # overrides
