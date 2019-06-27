namespace Ytake\Fluent\Logger;

type Option = shape(
  ?'socket_timeout' => int,
  ?'connection_timeout' => float,
  ?'backoff_mode' => int,
  ?'backoff_base' => int,
  ?'usleep_wait' => int,
  ?'persistent' => bool,
  ?'retry_socket' => bool,
  'max_write_retry' => int,
);
