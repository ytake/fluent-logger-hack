namespace Ytake\Fluent\Logger;

use namespace HH\Lib\Str;
use namespace HH\Lib\Experimental\IO;
use function fwrite;
use function feof;
use function fflush;
use function error_get_last;
use function array_key_exists;
use function usleep;
use function pow;
use function error_log;
use function var_export;
use function stream_set_blocking;

class LogWriteHandle implements IO\UserspaceHandle {

  private bool $isAwaitable = true;
  private ?Awaitable<mixed> $lastOperation;
  protected ?(function(): resource) $reconnector;

  public function __construct(
    private resource $socket,
    private Option $option
  ) {
    stream_set_blocking($this->socket, false);
  }

  public function setReconnector(
    (function(): resource) $reconnector
  ): void {
    $this->reconnector = $reconnector;
  }

  protected function queuedAsync<T>(
    (function(): Awaitable<T>) $next,
  ): Awaitable<T> {
    $last = $this->lastOperation;
    $queue = async {
      await $last;
      return await $next();
    };
    $this->lastOperation = $queue;
    return $queue;
  }

  private async function selectAsync(int $flags): Awaitable<void> {
    if (!$this->isAwaitable) {
      return;
    }
    if ($this->isEndOfFile()) {
      return;
    }
    try {
      await \stream_await($this->socket, $flags);
    } catch (\InvalidOperationException $_) {
      $this->isAwaitable = false;
    }
  }

  protected function writeBlocking(
    string $bytes
  ): int {
    $result = fwrite($this->socket, $bytes);
    if ($result === false) {
      throw new IO\WriteException('could not write message');
    }
    return $result as int;
  }

  public async function writeAsync(
    string $bytes
  ): Awaitable<mixed> {
    $buffer = $packed = $bytes;
    $retry  = $written = 0;
    return $this->queuedAsync(async () ==> {
      while ($written < Str\length($packed)) {
        $nwrite = $this->writeBlocking($buffer);
        if ($nwrite === 0) {
          if (!Shapes::idx($this->option, 'retry_socket', true)) {
            throw new Exception\SendErrorException('could not send entities');
          }
          if ($retry > Shapes::at($this->option, 'max_write_retry')) {
            throw new Exception\FailedWriteException(
              'failed fwrite retry: retry count exceeds limit.'
            );
          }
          $errors = error_get_last();
          if ($errors) {
            if (array_key_exists('message', $errors)
              && Str\search($errors['message'], 'errno=32 ') is nonnull
            ) {
              /* breaking pipes: we have to close socket manually */
              @\fclose($this->socket);
              $this->reconnect();
            } else if (array_key_exists('message', $errors)
              && Str\search($errors['message'], 'errno=11 ') is nonnull) {
              // we can ignore EAGAIN message. just retry.
            } else {
              $this->errorMessage($errors);
            }
          }
          $backOff = Shapes::idx(
            $this->option,
            'backoff_mode',
            Client::BACKOFF_TYPE_EXPONENTIAL
          );
          if ($backOff === Client::BACKOFF_TYPE_EXPONENTIAL) {
            $this->backoffExponential(3, $retry);
          } else {
            usleep(
              Shapes::idx($this->option, 'usleep_wait', Client::USLEEP_WAIT)
            );
          }
          $retry++;
          continue;
        }
        $written += $nwrite;
        $buffer = Str\slice($packed, $written);
        await $this->selectAsync(\STREAM_AWAIT_WRITE);
      }
    });
  }

  public async function closeAsync(): Awaitable<void> {
    await $this->flushAsync();
    @\fclose($this->socket);
  }

  final public function flushAsync(): Awaitable<void> {
    return $this->queuedAsync(async () ==> {
      @fflush($this->socket);
    });
  }

  protected function reconnect(): void {
    if ($this->socket is resource) {
      if ($this->reconnector is nonnull) {
        $callback = $this->reconnector;
        $this->socket = $callback();
      }
    }
  }

  final public function isEndOfFile(): bool {
    return feof($this->socket);
  }

  private function backoffExponential(
    int $base,
    int $attempt
  ): void {
    usleep(pow($base, $attempt) * 1000);
  }

  private function errorMessage<T>(
    Traversable<T> $errors
  ): void {
    error_log(
      "unhandled error detected. please report this issue to http://github.com/ytale/fluent-logger-hack/issues: "
      . var_export($errors, true)
    );
  }
}
