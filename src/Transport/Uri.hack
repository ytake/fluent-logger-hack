/**
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * This software consists of voluntary contributions made by many individuals
 * and is licensed under the MIT license.
 *
 * Copyright (c) 2019-2020 Yuuki Takezawa
 */

namespace Ytake\Fluent\Logger\Transport;

use type Ytake\Fluent\Logger\Exception\UnsupportedTransportException;
use namespace HH\Lib\{Str, Vec};

class Uri {

  const int DEFAULT_LISTEN_PORT = 24224;
  const string DEFAULT_ADDRESS = "127.0.0.1";

  protected vec<string> $supportedTransports = vec[
    "tcp",
    "unix",
  ];

  public function __construct(
    private string $host = Uri::DEFAULT_ADDRESS,
    private int $port = Uri::DEFAULT_LISTEN_PORT
  ) {}

  <<__Rx>>
  public function getNormalizeUri(
  ): string {
    $pos = Str\search($this->host, "://");
    if ($pos is nonnull) {
      $transport = Str\slice($this->host, 0, $pos);
      $host = Str\slice($this->host, $pos + 3);
      if(!Vec\filter(
        $this->supportedTransports,
        ($row) ==> $row === $transport
      )) {
        throw new UnsupportedTransportException(
          Str\format("transport `%s` does not support", $transport)
        );
      }
      return $this->detectTransportUri($transport, $host, $this->port);
    }
    $host = $this->host;
    if (Str\search($this->host, "::") is nonnull) {
      $host = Str\format("[%s]", Str\trim($this->host, "[]"));
    }
    return Str\format("tcp://%s:%d", $host, $this->port);
  }

  <<__Rx>>
  private function detectTransportUri(
    string $transport,
    string $host,
    int $port
  ): string {
    if ($transport === "unix") {
      return "unix://" . $host;
    }
    if (Str\search($host, "::") is nonnull) {
      $host = Str\format("[%s]", Str\trim($host, "[]"));
    }
    return Str\format("%s://%s:%d", $transport, $host, $port);
  }
}
