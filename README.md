# whim

Model asynchrony without the bad path hassles

[![Madlib Project Badge](https://img.shields.io/badge/madlib-purple?logo=github&logoSize=auto)](//github.com/madlib-lang/madlib) <!-- $MADLIB.projectBadge -->
[![whim v1.0.0](https://img.shields.io/badge/v1.0.0-purple?label=version)](//github.com/brekk/whim) <!-- $MADLIB.json.version -->

---

## The Problem

Wishes, Madlib's default form of asynchrony, are defined so that they carry an error type (`e`) and a value type (`a`):

```madlib
export type Wish e a = Wish((e -> {}) -> (a -> {}) -> {} -> {})
```

This carried error type tends to be different across modules. So when there is a `chain` operation on `Wish`, the compiler requires that the `e` is consistent. This means that you have to repeatedly modify your error type to be consistent across Wish-returning operations.

For example, if we have a read operation and a parse operation, the following will throw an error:

```madlib
// readFile  :: String -> Wish ReadError String
// parse     :: String -> Wish ParseError Config

// does not typecheck: ReadError vs ParseError
load = pipe(
  readFile,
  chain(parse)
)
```

### The Solution without Whims

In order to fix this, you need to manipulate the `ReadError` path, or both paths to a shared type:

```madlib
// readFile  :: String -> Wish Error String
// parse     :: String -> Wish ParseError Config

// does not typecheck: ReadError vs ParseError
load = pipe(
  readFile,
  Wish.mapRej((_) => ParseError("now they should unify")),
  chain(parse)
)
```

## The Solution with Whims

Whims wrap `Wish` values and are fixed across the error type (`type Whim a = Whim(Wish Failure a)`). This means that composition requires no conversion. You only need to convert once per boundary:

```madlib
readFileWhim = (path) => pipe(
  readFile,
  Whim.fromWish(where {
    ReadError(e) => Failure("project", "readError", "Unable to read file"),
  })
)(path)

parseWhim = (path) => pipe(
  parse,
  Whim.fromWish(where {
    ParseError(e) => Failure("project", "parseError", "Unable to parse file"),
  })
)(path)

load = pipe(
  readFileWish,
  chain(parseWhim)
)
```

### Unified `Failure` types

Because every step fails with the same unified type, `Failure`, there are multiple ways of segmenting failure while also eliding past the type system being mad at every juncture where the error type would change.

 - `catchTag` / `catchMessage` / `catchContext` are all exact matchers. `catchMaybe` is a Maybe-wrapped exact comparitor. `catchFail` allows you to express exactly how a Failure should resolve to a new Whim.
 - `collect` allows you to aggregate failures across multiple runs.
 - `withTimeout` allows you to express Failure bounded by time.
 - `bracket`, `bracketWithCancel` and `finally` allow for expressive and robust asynchrony with acquisition, use, and cleanup patterns.
