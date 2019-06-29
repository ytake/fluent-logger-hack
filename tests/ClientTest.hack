use type Facebook\HackTest\HackTest;
use namespace Ytake\Fluent\Logger;
use function Facebook\FBExpect\expect;

final class ClientTest extends HackTest {

  public function testShouldThrowSocketErrorException(): void {
    $client = new Logger\Client(
      new Logger\Transport\Uri('localhost')
    );
    expect(Shapes::toDict($client->getOptions()))
      ->toBeSame(dict[
        'socket_timeout' => Logger\Client::SOCKET_TIMEOUT,
        'connection_timeout' => Logger\Client::CONNECTION_TIMEOUT,
        'backoff_mode' => Logger\Client::BACKOFF_TYPE_USLEEP,
        'backoff_base' => 3,
        'usleep_wait' => Logger\Client::USLEEP_WAIT,
        'persistent' => false,
        'retry_socket' => true,
        'max_write_retry' => Logger\Client::MAX_WRITE_RETRY,
      ]);
  }
}
