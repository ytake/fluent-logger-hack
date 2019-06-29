use type Facebook\HackTest\{DataProvider, HackTest};
use namespace Ytake\Fluent\Logger;
use function Facebook\FBExpect\expect;

final class FluentLoggerTest extends HackTest {

  const string LOG_TAG = 'fluent-logger-hack.testing';

  public function testShouldReturnLoggerInstance(): void {
    $logger = $this->getLogger();
    expect($logger)->toBeInstanceOf(Logger\FluentLogger::class);
  }

  public async function testPostWillReturnTrueInTheCaseOfPostingSuccessfully(
  ): Awaitable<void> {
    $socket = fopen("php://memory", "a+");
    $logger = $this->getLogger($socket);
    $result = await $logger->sendEntityAsync(
      new Logger\Entity(self::LOG_TAG, dict['foo' => 'bar'])
    );
    expect($result)->toBeTrue();
    fseek($socket, 0);
    $actual = "";
    while ($string = fread($socket, 1024)) {
      $actual .= $string;
    }
    expect($actual)->toMatchRegExp('/["%s",%d,{"%s":"%s"}]/');
  }
  
  private function getLogger(
    resource $socket = fopen("php://memory", "a+")
  ): Logger\FluentLogger {
    $client = new Logger\Client(
      new Logger\Transport\Uri('localhost')
    );
    return new Logger\FluentLogger(
      new Logger\LogWriteHandle($socket, $client->getOptions())
    );
  }
}
