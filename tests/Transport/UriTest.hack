use type Ytake\Fluent\Logger\Transport\Uri;
use type Ytake\Fluent\Logger\Exception\UnsupportedTransportException;
use type Facebook\HackTest\{DataProvider, HackTest};
use function Facebook\FBExpect\expect;

final class UriTest extends HackTest {

  public function testShouldBe(): void {
    $uri = new Uri();
    expect($uri->getNormalizeUri())
      ->toBeSame('tcp://127.0.0.1:24224');
  }

  final public static function provideToTransport(
  ): varray<(string, int, string)> {
    return varray[
      tuple("localhost", 8080, "tcp://localhost:8080"),
      tuple("127.0.0.1", 8080, "tcp://127.0.0.1:8080"),
      tuple("tcp://localhost", 8080, "tcp://localhost:8080"),
      tuple("tcp://127.0.0.1", 8080, "tcp://127.0.0.1:8080"),
      tuple("unix:///var/fluentd", 0, "unix:///var/fluentd"),
      tuple("unix:///var/fluentd", 8080, "unix:///var/fluentd"),
      tuple("fe80::1", 8080, "tcp://[fe80::1]:8080"),
      tuple("tcp://fe80::1", 8081, "tcp://[fe80::1]:8081"),
      tuple("tcp://[fe80::1]", 8082, "tcp://[fe80::1]:8082"),
    ];
  }

  <<DataProvider("provideToTransport")>>
  public function testShouldReturnExpectedUri(
    string $host,
    int $port,
    string $expectedUri
  ): void {
    $uri = new Uri($host, $port);
    expect($uri->getNormalizeUri())->toBeSame($expectedUri);
  }

  public function testGetTransportUriCauseExcpetion(): void {
    $uri = new Uri("udp://localhost", 1192);
    expect(() ==> $uri->getNormalizeUri())
      ->toThrow(
        UnsupportedTransportException::class,
        'transport `udp` does not support'
      );
  }
}
