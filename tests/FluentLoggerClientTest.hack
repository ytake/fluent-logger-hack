use type Facebook\HackTest\HackTest;
use namespace Ytake\Fluent\Logger;
use function Facebook\FBExpect\expect;

final class FluentLoggerClientTest extends HackTest {

  public function testShouldThrowSocketErrorException(): void {
    $client = new Logger\FluentLoggerClient(
      new Logger\Transport\Uri('localhost')
    );
    expect(() ==> new Logger\LogWriteHandle($client))
      ->toThrow(Logger\Exception\SocketErrorException::class);
  }
}
