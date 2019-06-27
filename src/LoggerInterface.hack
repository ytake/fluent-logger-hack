namespace Ytake\Fluent\Logger;

interface LoggerInterface {

  public function sendLogAsync(
    string $tag,
    dict<arraykey, mixed> $data
  ): Awaitable<bool>;

  public function sendEntityAsync(
    Entity $entity
  ): Awaitable<bool>;
}
