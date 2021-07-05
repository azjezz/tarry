namespace Tarry\Compresser;

interface ICompresser {
  public function compress(string $data)[]: string;
}
