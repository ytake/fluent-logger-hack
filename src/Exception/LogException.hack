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

namespace Ytake\Fluent\Logger\Exception;

use type Exception;
use type Ytake\Fluent\Logger\Entity;

final class LogException extends Exception {

  public function __construct(
    protected Entity $entity,
    protected string $message = "",
    protected int $code = 0,
    protected ?Exception $previous = null)
  {
    parent::__construct($message, $code, $previous);
  }

  public function getEntity(): Entity {
    return $this->entity;
  }
}
