namespace Ytake\Fluent\Logger;

use type Ytake\Fluent\Logger\Transport\Uri;
use function stream_socket_client;
use function error_get_last;
use function stream_set_timeout;
use const STREAM_CLIENT_CONNECT;
use const STREAM_CLIENT_PERSISTENT;

class FluentLoggerClient {

  const float CONNECTION_TIMEOUT = 3.0;
  const int SOCKET_TIMEOUT = 3;
  const int MAX_WRITE_RETRY = 5;
  const int USLEEP_WAIT = 1000; /* 1000 means 0.001 sec */
  /**
   * backoff strategies: default usleep
   * attempts | wait
   * 1        | 0.003 sec
   * 2        | 0.009 sec
   * 3        | 0.027 sec
   * 4        | 0.081 sec
   * 5        | 0.243 sec
   **/
  const int BACKOFF_TYPE_EXPONENTIAL = 0x01;
  const int BACKOFF_TYPE_USLEEP = 0x02;

  protected vec<string> $acceptableOptions = vec[
    "socket_timeout",
    "connection_timeout",
    "backoff_mode",
    "backoff_base",
    "usleep_wait",
    "persistent",
    "retry_socket",
    "max_write_retry",
  ];

  protected Option $options = shape(
    "socket_timeout" => self::SOCKET_TIMEOUT,
    "connection_timeout" => self::CONNECTION_TIMEOUT,
    "backoff_mode" => self::BACKOFF_TYPE_USLEEP,
    "backoff_base" => 3,
    "usleep_wait" => self::USLEEP_WAIT,
    "persistent" => false,
    "retry_socket" => true,
    'max_write_retry' => self::MAX_WRITE_RETRY,
  );

  protected int $maxWriteRetry = 5;

  public function __construct(
    private Uri $transportUri,
    ?Option $options = null,
  ) {
    if(!$options is nonnull) {
      $options = $this->options;
    }
    $this->mergeOptions($options);
  }

  public function mergeOptions(
    Option $options
  ): void {
    $this->options = $options;
  }

  public function setOptions(
    Option $options
  ): void {
    $this->mergeOptions($options);
  }

  public function getOptions(): Option {
    return $this->options;
  }

  public function create(): resource {
    $connectOption = STREAM_CLIENT_CONNECT;
    if (Shapes::idx($this->options, 'persistent', false)) {
      $connectOption |= STREAM_CLIENT_PERSISTENT;
    }
    $errno = 0;
    $errstr = '';
    // could not suppress warning without ini setting.
    // for now, we use error control operators.
    $socket = @stream_socket_client(
      $this->transportUri->getNormalizeUri(),
      &$errno,
      &$errstr,
      Shapes::idx($this->options, 'connection_timeout', self::CONNECTION_TIMEOUT),
      $connectOption
    );
    if (!$socket) {
      $errors = error_get_last();
      if (!$errors is nonnull) {
        throw new Exception\SocketErrorException('socket error.');
      }
      throw new Exception\SocketErrorException($errors['message']);
    }
    // set read / write timeout.
    stream_set_timeout(
      $socket,
      Shapes::idx($this->options, 'socket_timeout', self::SOCKET_TIMEOUT),
    );
    return $socket;
  }
}
