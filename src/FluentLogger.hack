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

class FluentLogger implements LoggerInterface, \IAsyncDisposable {

  public function __construct(
    protected LogWriteHandle $handle,
    protected ErrorHandlerInterface $errorHandler = new DefaultErrorHandler(),
    protected PackerInterface $packer = new JsonPacker(),
  ) {}

  protected async function postAsync(
    Entity $entity
  ): Awaitable<bool> {
    try {
      await $this->handle->writeAsync($this->packer->pack($entity));
    } catch (Exception\AbstractLoggerException $e) {
      await $this->handle->closeAsync();
      await $this->errorHandler->handleAsync(static::class, $entity, $e->getMessage());
      return false;
    }
    return true;
  }

  public async function sendLogAsync(
    string $tag,
    dict<arraykey, mixed> $data
  ): Awaitable<bool> {
    return await $this->postAsync(new Entity($tag, $data));
  }

  public async function sendEntityAsync(
    Entity $entity
  ): Awaitable<bool> {
    return await $this->postAsync($entity);
  }

  public async function __disposeAsync(): Awaitable<void> {
    await $this->handle->closeAsync();
  }
}
