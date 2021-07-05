namespace Tarry\Compresser;

final class BZIPCompresser implements ICompresser {
  public function __construct(private int $level = 9)[] {}

  public static function create(int $level = 9)[]: BZIPCompresser {
    return new self($level);
  }

  public function compress(string $data)[]: string {
    return \bzcompress($data, $this->level) as string;
  }
}
