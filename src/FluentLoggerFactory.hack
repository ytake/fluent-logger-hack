namespace Ytake\Fluent\Logger;

class FluentLoggerFactory {

  public function getLogger(
    string $host = Transport\Uri::DEFAULT_ADDRESS,
    int $port = Transport\Uri::DEFAULT_LISTEN_PORT,
    ?Option $options = null,
  ): FluentLogger {
    $client = new Client(new Transport\Uri($host, $port), $options);
    return new FluentLogger(new LogWriteHandle(
      $client->create(), $client->getOptions())
    );
  }
}
