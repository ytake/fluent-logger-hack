use type Facebook\HackTest\HackTest;
use namespace Ytake\Fluent\Logger;

use function Facebook\FBExpect\expect;

final class FluentLoggerTest extends HackTest {

  const string LOG_TAG = 'fluent-logger-hack.testing';

  public async function testPostWillReturnTrueInTheCaseOfPostingSuccessfully(
  ): Awaitable<void> {
    $socket = fopen("php://memory", "a+");
    await using $logger = $this->getLogger($socket);
    $_ = $logger->sendEntityAsync(
      new Logger\Entity(self::LOG_TAG, dict['foo' => 'bar'])
    );
    fseek($socket, 0);
    $actual = "";
    while (fread($socket, 1024)) {
      $string = fread($socket, 1024);
      $actual .= $string;
    }
    expect($actual)->toMatchRegExp('/["%s",%d,{"%s":"%s"}]/');
  }

  <<__ReturnDisposable>>
  private function getLogger(
    resource $socket = fopen("php://memory", "a+")
  ): Logger\FluentLogger {
    $client = new Logger\Client(
      new Logger\Transport\Uri('localhost')
    );
    return new MockFluentLogger(
      new Logger\LogWriteHandle($socket, $client->getOptions())
    );
  }
}

// for testing only
final class MockFluentLogger extends Logger\FluentLogger {
  <<__Override>>
  public async function __disposeAsync(): Awaitable<void> {
    await null;
  }
}
