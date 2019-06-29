namespace Ytake\Fluent\Logger;

class FluentLogger implements LoggerInterface {

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
    } catch (Exception\SocketErrorException $e) {
      await $this->handle->closeAsync();
      await $this->errorHandler->handleAsync(static::class, $entity, $e->getMessage());
      return false;
    } catch (Exception\FailedWriteException $e) {
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
}
