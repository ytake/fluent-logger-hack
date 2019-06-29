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
 * Copyright (c) 2019 Yuuki Takezawa
 */

namespace Ytake\Fluent\Logger;

class FluentLoggerFactory {

  <<__ReturnDisposable>>
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
