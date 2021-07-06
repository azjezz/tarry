# Tarry

Tarry is a small utility for building TAR archives.

## Installation

This package is available via `composer`:

```sh
composer require azjezz/tarry
```

## Features

### Supported

- ability to create a TAR archive.
- GZIP compression
- BZIP compression
- adding files
- modifying file permissions, user id, group id, and mtime.

### TODO

- add support for long filenames.
- extracting existing archives.
- modifying existing archives
- more?

## Usage

```hack
use namespace Tarry;
use namespace HH\Lib\File;

async function main(): Awaitable<void> {
  $archive = Tarry\ArchiveBuilder::create()
    ->withCompressionAlgorithm(CompressionAlgorithm::GZIP)
    ->withCompressionLevel(9)
    ->withNode(shape(
      'filename' => 'hello-world.txt',
      'content' => 'Hello, World!',
    ))
    ->build();

  await $archive->saveToFile('hello-world.tar.gz');
}
```

## License

The MIT License (MIT). Please see [`LICENSE`](./LICENSE) for more information.
