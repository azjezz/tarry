namespace Tarry\Compresser;

final class GZIPCompresser implements ICompresser {
  public function __construct(private int $level = 9)[] {}

  public static function create(int $level = 9)[]: GZIPCompresser {
    return new self($level);
  }

  public function compress(string $data)[]: string {
    return \gzencode($data, $this->level) as string;
  }
}
