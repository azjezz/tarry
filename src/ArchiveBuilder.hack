namespace Tarry;

use namespace HH\Lib\{Math, Str, Vec};

final class ArchiveBuilder {
  const DEFAULT_GZIP_LEVEL = 9;
  const DEFAULT_BZIP_LEVEL = 9;

  public function __construct(
    private CompressionAlgorithm $compressionAlgorithm,
    private ?int $compressionLevel = null,
    private vec<ArchiveNode> $nodes = vec[],
  )[] {}

  public static function create()[]: ArchiveBuilder {
    return new ArchiveBuilder(CompressionAlgorithm::NONE);
  }

  public function withNode(ArchiveNode $node)[]: ArchiveBuilder {
    return new self(
      $this->compressionAlgorithm,
      $this->compressionLevel,
      Vec\concat($this->nodes, vec[$node]),
    );
  }

  public function withCompressionAlgorithm(
    CompressionAlgorithm $compressionAlgorithm,
  )[]: ArchiveBuilder {
    return new self(
      $compressionAlgorithm,
      $this->compressionLevel,
      $this->nodes,
    );
  }

  public function withCompressionLevel(
    int $compressionLevel,
  )[]: ArchiveBuilder {
    return new self(
      $this->compressionAlgorithm,
      $compressionLevel,
      $this->nodes,
    );
  }

  public function build()[rx_local]: string {
    $archive = '';
    foreach ($this->nodes as $node) {
      $archive .= static::buildNode($node);
    }

    // append TAR footer
    $archive .= \pack('a512', '');
    $archive .= \pack('a512', '');

    switch ($this->compressionAlgorithm) {
      case CompressionAlgorithm::NONE:
        return $archive;

      case CompressionAlgorithm::GZIP:
        return \gzencode(
          $archive,
          $this->compressionLevel ?? self::DEFAULT_GZIP_LEVEL,
        ) as string;

      case CompressionAlgorithm::BZIP:
        return \bzcompress(
          $archive,
          $this->compressionLevel ?? self::DEFAULT_BZIP_LEVEL,
        ) as string;
    }
  }

  <<__Memoize>>
  private static function buildNode(ArchiveNode $node)[rx_local]: string {
    $content = $node['content'];
    $length = Str\length($content);
    $node['size'] = $length;

    $header = static::buildHeader($node);
    $body = '';
    for ($s = 0; $s < $length; $s += 512) {
      $body .= \pack('a512', Str\slice($content, $s, 512));
    }

    return $header.$body;
  }

  <<__Memoize>>
  private static function buildHeader(ArchiveNode $node)[rx_local]: string {
    $header = '';

    $name_length = Str\length($node['filename']);
    // FIXME(azjezz): we could use GNU longlink here to support long filenames
    invariant(
      $name_length <= 100,
      'filename (%s) is too long',
      $node['filename'],
    );

    // values are needed in octal
    $user_id = Str\format(
      '%6s ',
      Math\base_convert((string)($node['user_id'] ?? 0), 10, 8),
    );

    $group_id = Str\format(
      '%6s ',
      Math\base_convert((string)($node['group_id'] ?? 0), 10, 8),
    );

    $permissions = Str\format(
      '%6s ',
      Math\base_convert((string)($node['permissions'] ?? 0664), 10, 8),
    );

    $size = Str\format(
      '%11s ',
      Math\base_convert((string)($node['size'] ?? 0), 10, 8),
    );

    $modification_time = Str\format(
      '%11s',
      Math\base_convert((string)($node['modification_time'] ?? \time()), 10, 8),
    );

    $data_first = \pack(
      'a100a8a8a8a12A12',
      $node['filename'],
      $permissions,
      $user_id,
      $group_id,
      $size,
      $modification_time,
    );

    $data_last = \pack(
      'a1a100a6a2a32a32a8a8a155a12',
      /* typeflag = is_dir($node) ? '5' : */'0',
      '',
      'ustar',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    );

    $checksum = 0;
    for ($i = 0; $i < 148; $i++) {
      $checksum += \ord($data_first[$i]);
    }

    $checksum += 256;
    for ($i = 156, $j = 0; $i < 512; $i++, $j++) {
      $checksum += \ord($data_last[$j]);
    }

    $header .= $data_first;
    $header .= \pack('a8', Math\base_convert((string)$checksum, 10, 8));
    $header .= $data_last;

    return $header;
  }
}
