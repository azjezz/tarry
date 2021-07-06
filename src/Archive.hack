namespace Tarry;

use namespace HH\Lib\{IO, File};

final class Archive {
  public function __construct(private IO\SeekableReadHandle $handle)[] {}

  public function getHandle(): IO\SeekableReadHandle {
    return $this->handle;
  }

  /**
   * @param float|null $timeout_ns Timeout for write operation in nanoseconds, or null for no timeout.
   */
  public async function saveToFile(
    string $destination,
    File\WriteMode $write_mode = File\WriteMode::OPEN_OR_CREATE,
    ?int $timeout_ns = null,
  ): Awaitable<void> {
    $file = File\open_write_only($destination, $write_mode);
    await $this->saveTo($file, $timeout_ns);
    $file->close();
  }

  /**
   * @param float|null $timeout_ns Timeout for write operation in nanoseconds, or null for no timeout.
   */
  public async function saveTo(
    IO\WriteHandle $target,
    ?int $timeout_ns = null,
  ): Awaitable<void> {
    $handle = $this->getHandle();
    $handle->seek(0);
    $content = await $handle->readAllAsync();
    await $target->writeAllAsync($content, $timeout_ns);
  }
}
