namespace Ytake\Fluent\Logger;

interface LoggerInterface {

  public function sendLog(
    string $tag,
    dict<arraykey, mixed> $data
  ): void;

  public function sendEntity(
    Entity $entity
  ): void;
}
