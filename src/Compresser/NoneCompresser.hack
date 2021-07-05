namespace Tarry\Compresser;

final class NoneCompresser implements ICompresser {
  public static function create()[]: NoneCompresser {
    return new self();
  }

  public function compress(string $data)[]: string {
    return $data;
  }
}
